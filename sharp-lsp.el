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

(defvar sharp-port "8080"
  "Port of the lps server.")

(defvar sharp-address "192.168.0.100"
  "IP address of the lsp server.")

(defvar sharp-lsp-process "sharp-lsp-process"
  "Name of process.")

(defvar sharp-buffer-name "*sharp-lsp*")

(defun sharp-lsp-sentinel(proc msg)
  "Call 'when make-network-process' status was changed.
PROC - process name
MSG - message"
  (when (string= msg "connection broken by remote peer\n")
    (message (format "Client %s has quit" proc)))
  (message "Updated state"))

(defun sharp-lsp-start ()
  "Start sharp lsp server."
  (interactive)
  (make-network-process :name sharp-lsp-process
                        :host sharp-address
                        :service sharp-port
                        :buffer sharp-buffer-name
                        :sentinel #'sharp-lsp-sentinel))

(defun sharp-lsp-stop ()
  "Stop sharp lsp server."
  (interactive)
  (delete-process sharp-lsp-process))

(provide 'sharp-lsp)
;;; sharp-lsp.el ends here
