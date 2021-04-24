;;; sharp-lsp.el --- Client for sharp-lsp     -*- lexical-binding: t; -*-

;; Author: homestop
;; Keywords: lisp

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This package implement interaction with sharp-lsp

;;; Code:

(require 'json)
(require 'projectile)

(defvar sharp-server-port "8080"
  "Port of the lps server.")

(defvar sharp-server-address "192.168.0.100"
  "IP address of the lsp server.")

(defvar sharp-process-name "sharp-lsp-process"
  "Name of process.")

(defvar sharp-buffer-name "*sharp-lsp*")

(defvar jsonrpc-version "2.0")

(defun sharp-lsp-sentinel(proc msg)
  "Call 'when make-network-process' status was changed.
PROC - process name
MSG - message"
  (when (string= msg "connection broken by remote peer\n")
    (message (format "Client %s has quit" proc)))
  (message "Updated state"))

(defun sharp-message-object (id method &optional params)
  "Make message object as json, return string object type.
ID - id of message
METHOD - requset method
&OPTIONAL PARAMS - additional paramenters for message, should look like `((param . ,\"object\"))"
  (json-encode `((id . ,id) (jsonrpc . ,jsonrpc-version) (method . ,method) (params . ,params))))

(defun sharp-send-message (msg-obj)
  "Wrapper for 'process-send-string'.
MSG-OBJ - type of message like 'sharp-message-object'"
  (process-send-string sharp-process-name msg-obj))

(defun sharp-message-initialize (id &optional root-path)
  "Send init message to server.
ID - id of message
&OPTIONAL ROOT-PATH - project root"
  (let ((path (unless root-path (projectile-project-root))))
    (if (eq path nil) (path root-path))
    (sharp-send-message (sharp-message-object id "initialize"
                                             `((rootPath . ,path))))))
(defun sharp-message-textDocument/didOpen ()
  "Send textDocument/didOpen to server."
  (interactive)
  (sharp-send-message (sharp-message-object 1 "textDocument/didOpen"
                                            `((path . ,buffer-file-name)))))

(defconst sharp-completion-keywords '("using" "class" "System"))
(defun sharp-message-textDocument/completion ()
  (interactive)
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
         (start (max (car bounds) (comint-line-beginning-position)))
         (end (cdr bounds)))
    (list start end sharp-completion-keywords . nil)))

(defun sharp-language--filter (proc msg)
  "Listen responce from server."
  (cond ((string= msg "initialize") (message "from sharp language filter : initialize"))

        
        ((string= msg "") (message ""))))

(defun sharp--session-start ()
  "Start sharp lsp server session."
  (make-network-process :name sharp-process-name
                        :host sharp-server-address
                        :service sharp-server-port
                        :filter 'sharp-language--filter
                        :buffer sharp-buffer-name))

(defun sharp--sesstion-stop ()
  "Stop sharp lsp server session."
  (delete-process sharp-process-name))

(defun sharp-start-client ()
  "Start sharp client."
  (interactive)
  (sharp--session-start)
  (sharp-message-initialize 1 projectile-project-root)
  (sharp-message-textDocument/didOpen))

;;;###autoload
(define-minor-mode sharp-lsp-mode
  "Sharp lsp client mode"
  :lighter " Started sharp-lsp-mode"
  (if sharp-lsp-mode
      (progn
        (add-hook 'sharp-lsp-mode-hook #'sharp-start-client nil t)
        (add-hook 'completion-at-point-functions #'sharp-message-textDocument/completion nil t))
    (remove-hook 'sharp-lsp-mode-hook #'sharp-start-client t)
    (remove-hook 'completion-at-point-functions #'sharp-message-textDocument/completion t)))

(provide 'sharp-lsp)
;;; sharp-lsp.el ends here
