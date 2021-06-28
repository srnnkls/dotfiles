;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here

;;; General settings and appearance
;; (menu-bar-mode 1)

;; (load-theme 'doom-material t)

(set-frame-font "Monaco 11" nil t)
(setq frame-title-format "%b")
;; (setq icon-title-format nil)

;; (doom-load-envvars-file "~/.doom.d/myenv")

(map! (:leader
        (:prefix "w"
         :desc "Close window and kill buffer" :n "C" (λ! (kill-this-buffer) (+workspace/close-window-or-workspace))
         :n "U" #'winner-redo))
      :i "C-h" #'evil-delete-backward-char-and-join
      :i "C-k" #'kill-line
      :i "C-S-k" #'evil-insert-digraph
      :i "C-d" #'evil-delete-char
      ;; I like to be able to do micro-movements
      ;; within insert state
      :i "C-f" #'forward-char
      :i "C-b" #'backward-char
      ;; Redefine help in insert state
      :i "C-?" #'help-command
      :niv "C-S-SPC" (λ! (push-mark))
      :niv "M-J" #'drag-stuff-down
      :niv "M-K" #'drag-stuff-up
      :niv "M-h" #'backward-sexp
      :niv "M-l" #'forward-sexp
      :niv "M-j" #'down-list
      :niv "M-k" #'backward-up-list
      :nv "DEL" (λ! (evil-previous-line) (evil-end-of-line))
      :n "U" #'undo-fu-only-redo
      :nv "C-i" #'better-jumper-jump-forward
      :nv "C-o" #'better-jumper-jump-backward
      :nv "C-/" #'avy-goto-char-timer
      :nv "C-s" #'avy-goto-char-2
      :nv "C-'" #'ivy-resume
      :nv "C-;" #'avy-resume)

(map!   :gv "s-x"  #'counsel-M-x
        :g "s-z"   #'eval-expression
        :g "s-`"   #'other-frame
        :g "M-;"   #'+emacs-lisp/open-repl
        :g "s-/"   #'swiper-isearch
        :g "s-f"   #'counsel-grep-or-swiper
        :g "s-o"   #'+ivy/jump-list
        :g "s-p"   #'counsel-yank-pop
        :g "s-h"   #'evil-window-decrease-width
        :g "s-l"   #'evil-window-increase-width
        :g "s-;"   #'ace-window
        :n "C-S-b" #'scroll-other-window
        :n "C-S-f" #'scroll-other-window-down
        :g "s-j"   #'evil-window-next
        :g "s-k"   #'evil-window-prev
        (:when (featurep! :ui workspaces)
          :g "s-1"   (λ! (+workspace/switch-to 0))
          :g "s-2"   (λ! (+workspace/switch-to 1))
          :g "s-3"   (λ! (+workspace/switch-to 2))
          :g "s-4"   (λ! (+workspace/switch-to 3))
          :g "s-5"   (λ! (+workspace/switch-to 4))
          :g "s-6"   (λ! (+workspace/switch-to 5))
          :g "s-7"   (λ! (+workspace/switch-to 6))
          :g "s-8"   (λ! (+workspace/switch-to 7))
          :g "s-9"   (λ! (+workspace/switch-to 8))
          :g "s-0"   #'+workspace/switch-to-last
          :g "s-t"   #'+workspace/new
          :g "s-T"   #'+workspace/display))

(map! :map (evil-ex-search-keymap evil-ex-completion-map)
      "C-h" #'evil-delete-backward-char-and-join
      "C-d" #'evil-delete-char
      "C-k" #'kill-line)

(map! :map +popup-mode-map
      "C-`" #'+popup/toggle)

;; REPLs
(map! :map comint-mode-map
      :g "s-'" #'jump-to-previous-window
      :g "C-r" #'isearch-backward
      :n "C-p" #'comint-previous-input
      :n "C-n" #'comint-next-input
      :i "C-k" #'kill-line)

(define-key! :keymaps +default-minibuffer-maps
      "C-h" #'delete-backward-char
      "C-?" #'help-command
      "C-k" #'kill-line
      "C-j" #'exit-minibuffer
      "C-p" #'previous-history-element
      "C-n" #'next-history-element)

;; A Doom convention where C-r on popups and interactive searches will invoke
;; ivy/helm for their superior filtering.
(when-let (command (cond ((featurep! :completion ivy)
                          #'counsel-minibuffer-history)
                         ((featurep! :completion helm)
                          #'helm-minibuffer-history)))
  (define-key!
    :keymaps (append +default-minibuffer-maps
                     (when (featurep! :editor evil +everywhere)
                       '(evil-ex-completion-map)))
    "C-r" command))

;; yadm
(use-package! yadm
  :config
  (map! :leader
        (:prefix "f"
         "." #'yadm-find-file
         ">" #'yadm-dired)))

;; Projectile
(after! projectile
  (add-to-list 'projectile-globally-ignored-directories ".venv"))

;; Snipe/Avy

(after! evil-snipe
  (setq evil-snipe-scope 'visible))
;;   (define-key evil-snipe-parent-transient-map (kbd "C-;")
;;     (evilem-create 'evil-snipe-repeat
;;                    :bind ((evil-snipe-scope 'whole-buffer)
;;                           (evil-snipe-enable-highlight)
;;                           (evil-snipe-enable-incremental-highlight)))))

;; Evil
(after! evil
  (evil-ex-define-cmd "t" "copy"))

;; Targets.el
(use-package! targets
  :init
  (setq targets-user-text-objects '((pipe "|" nil separator)
                                    (paren "(" ")" pair)
                                    (bracket "[" "]" pair)
                                    (curly "{" "}" pair)))
  :config
  (targets-setup t))


(defmacro define-and-bind-text-object (key start-regex end-regex)
  (let ((inner-name (make-symbol "inner-name"))
        (outer-name (make-symbol "outer-name")))
    `(progn
       (evil-define-text-object ,inner-name (count &optional beg end type)
         (evil-select-paren ,start-regex ,end-regex beg end type count nil))
       (evil-define-text-object ,outer-name (count &optional beg end type)
         (evil-select-paren ,start-regex ,end-regex beg end type count t))
       (define-key evil-inner-text-objects-map ,key (quote ,inner-name))
       (define-key evil-outer-text-objects-map ,key (quote ,outer-name)))))

(define-and-bind-text-object "$" "\\$" "\\$")

;; Counsel/Ivy
(defun counsel-switch-to-fzf ()
  "Switch to counsel-fzf, preserving current input."
  (interactive)
  (counsel-file-jump ivy-text (ivy-state-directory ivy-last)))

(after! counsel
  (setq counsel-find-file-at-point t
        counsel-rg-base-command "rg -M 240 --with-filename --no-heading --line-number --color never %s || true"))

(after! ivy
  (defun +ivy--kill-current-candidate-buffer ()
    (setf (ivy-state-preselect ivy-last) ivy--index)
    (setq ivy--old-re nil
          ivy--all-candidates (ivy--buffer-list "" ivy-use-virtual-buffers (ivy-state-predicate ivy-last)))
    (let ((ivy--recompute-index-inhibit t))
      (ivy--exhibit))))

  ;; (advice-add 'ivy--kill-current-candidate-buffer
  ;;             :override #'+ivy--kill-current-candidate-buffer))

(use-package! ivy-avy
  :after ivy)

(map! :after ivy
      (:map ivy-minibuffer-map
       "C-n" #'ivy-next-line
       "C-p" #'ivy-previous-line
       "C-l" #'ivy-partial-or-done
       "C-SPC" #'ivy-partial-or-done
       "C-h" #'ivy-backward-delete-char
       "C-o" #'ivy-dispatching-done
       "M-o" #'hydra-ivy/body
       [C-return] #'ivy-mark
       [C-S-return] #'ivy-unmark)
      :map ivy-switch-buffer-map
      "C-n" #'ivy-next-line
      "C-p" #'ivy-previous-line
      "C-k" #'ivy-switch-buffer-kill
      :map counsel-find-file-map
      "C-t" #'counsel-switch-to-fzf)

;; Ispell
(setq ispell-dictionary "en")

;; persistent overlays
(after! persistent-overlays
  (setq persistent-overlays-directory "~/.doomemacs.d/.local/etc/overlays/"))
;; (define-globalized-minor-mode global-persistent-overlays-mode persistent-overlays-minor-mode #'persistent-overlays-minor-mode)
  ;; #'global-persistent-overlays-minor-mode)

;; Company
(after! company
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 5)
  (map! :map company-active-map
        "C-h" #'backward-delete-char
        "C-?" #'company-show-doc-buffer
        "C-l" #'company-complete-selection
        "C-SPC" #'company-complete-selection
        "C-'" #'counsel-company))

(after! company-box
  (setq company-box-doc-enable nil))

;; jupyter
(use-package! jupyter
  :config
  (setq jupyter-repl-echo-eval-p t)
  (set-popup-rule! "^\\*jupyter-repl" :quit nil :side 'right :width 90 :slot 1)
  (set-popup-rule! "^\\*jupyter-kernels" :select t :side 'right :width 121 :slot 1)
  (after! savehist
    (add-to-list 'savehist-additional-variables 'jupyter-server-kernel-names))

  (map! :map jupyter-repl-mode-map
        :g "s-'" #'jump-to-previous-window
        :g "C-r" #'isearch-backward
        :n "C-p" #'jupyter-repl-history-previous
        :n "C-n" #'jupyter-repl-history-next
        :i "M-p" #'jupyter-repl-history-previous-matching
        :i "M-n" #'jupyter-repl-history-next-matching
        :i "C-p" #'complete-previous-or-repl-history-previous
        :i "C-n" #'complete-next-or-repl-history-next
        :i "C-k" #'kill-line
        :map jupyter-server-kernel-list-mode-map
        :n "r" #'jupyter-server-kernel-list-name-kernel
        :n "R" #'jupyter-server-kernel-list-do-restart
        :n "x" #'jupyter-server-kernel-list-do-shutdown
        :map python-mode-map
        :g "s-'" #'jupyter-repl-pop-to-buffer))

(map! (:after jupyter
       (:leader
        (:prefix-map ("j" . "Jupyter")
        :desc "Associate buffer" "a" #'jupyter-repl-associate-buffer
        :desc "Connect to server kernel" "c" #'jupyter-connect-server-repl
        :desc "Switch to repl" "j" #'+ivy-switch-jupyer-repl
        :desc "Switch to repl" "r" #'+ivy-switch-jupyer-repl
        :desc "Open kernel list" "k" #'jupyter-server-list-kernels))))

(defun +jupyter-server-kernel-list-new-repl ()
  "Connect a REPL to the kernel corresponding to the current entry."
  (interactive)
  (when-let* ((id (tabulated-list-get-id)))
    (let* ((repl-name (jupyter-server-kernel-name jupyter-current-server id))
           (jupyter-current-client
           (jupyter-connect-server-repl jupyter-current-server id repl-name)))
      (revert-buffer)
      (jupyter-repl-pop-to-buffer))))

(advice-add 'jupyter-server-kernel-list-new-repl
            :override #'+jupyter-server-kernel-list-new-repl)

(defun +ivy-switch-jupyer-repl ()
  "Switch to another jupyer repl buffer."
  (interactive)
  (ivy-read "Switch to repl: " #'internal-complete-buffer
            :keymap ivy-switch-buffer-map
            :predicate #'+ivy--is-jupyter-repl-buffer-p
            ;; :preselect (buffer-name (other-buffer (current-buffer)))
            :action #'pop-to-buffer
            :matcher #'ivy--switch-buffer-matcher
            :caller #'+ivy-switch-jupyer-kernel))

(defun +ivy--is-jupyter-repl-buffer-p (buffer)
  (let ((buffer (car buffer)))
    (when (not (stringp buffer))
      (setq buffer (buffer-name buffer)))
    (string-match-p "^\\*jupyter-repl" buffer)))

(defun jump-to-previous-window ()
  (interactive)
  (select-window (previous-window)))

(defun complete-next-or-repl-history-next ()
  (interactive)
  (if (eq (point) (jupyter-repl-cell-code-beginning-position))
      (progn (jupyter-repl-history-next)
             (goto-char (jupyter-repl-cell-code-beginning-position)))
    (evil-complete-next)))

(defun complete-previous-or-repl-history-previous ()
  (interactive)
  (if (eq (point) (jupyter-repl-cell-code-beginning-position))
      (progn (jupyter-repl-history-previous)
             (goto-char (jupyter-repl-cell-code-beginning-position)))
    (evil-complete-previous)))

;; ESS
(after! ess-r-mode
  (add-hook! 'inferior-ess-mode-hook #'smartparens-mode)
  (add-hook! 'ess-mode-hook '(rainbow-delimiters-mode))
  (set-popup-rule! "^\\*R" :quit nil :side 'right :width 82 :slot 1)
  (setq ess-use-ido nil)
  (set-evil-initial-state! 'ess-help-mode 'motion)
  ;; (set-company-backend! 'ess-r-mode (car ess-r-company-backends))
  ;; (set-company-backend! 'inferior-ess-r-mode (car ess-r-company-backends))
  ;; ESS buffers should not be cleaned up automatically
  ;; (add-hook 'inferior-ess-mode-hook #'doom|mark-buffer-as-real)
  ;; Smartparens broke this a few months ago

  (custom-set-variables '(ess-R-font-lock-keywords
                          (quote ((ess-R-fl-keyword:keywords . t)
                            (ess-R-fl-keyword:constants . t)
                            (ess-R-fl-keyword:modifiers . t)
                            (ess-R-fl-keyword:fun-defs . t)
                            (ess-R-fl-keyword:assign-ops . t)
                            (ess-R-fl-keyword:%op% . t)
                            (ess-fl-keyword:fun-calls . t)
                            (ess-fl-keyword:numbers . t)
                            (ess-fl-keyword:operators . t)
                            (ess-fl-keyword:delimiters)
                            (ess-fl-keyword:= . t)
                            (ess-R-fl-keyword:F&T . t)))))

  (custom-set-variables '(inferior-ess-R-font-lock-keywords
                         (quote (ess-S-fl-keyword:prompt . t)
                           (ess-R-fl-keyword:messages . t)
                           (ess-R-fl-keyword:modifiers . t)
                           (ess-R-fl-keyword:fun-defs . t)
                           (ess-R-fl-keyword:keywords . t)
                           (ess-R-fl-keyword:assign-ops . t)
                           (ess-R-fl-keyword:constants . t)
                           (ess-R-fl-keyword:matrix-labels . t)
                           (ess-fl-keyword:fun-calls . t)
                           (ess-fl-keyword:numbers . t)
                           (ess-fl-keyword:operators . t)
                           (ess-fl-keyword:delimiters . nil)
                           (ess-fl-keyword:= . t)
                           (ess-R-fl-keyword:F&T . t))))

  ;; Functions related to the pipe. Credit to J. A. Branham
  ;; https://github.com/jabranham/emacs/blob/master/init.el

  (defun ess-beginning-of-pipe-or-end-of-line ()
    "Find point position of end of line or beginning of pipe %>%."
    (if (search-forward "%>%" (line-end-position) t)
        (let ((pos (progn
                     (beginning-of-line)
                     (search-forward "%>%" (line-end-position))
                     (backward-char 3)
                     (point))))
          (goto-char pos))
      (end-of-line)))

  (defun ess-next-pipe-or-end-of-line ()
    "Find point position of next pipe %>%."
    (if (search-forward "%>%" nil t)
        (let ((pos (progn
                     (beginning-of-line)
                     (search-forward "%>%")
                     (backward-char 4)
                     (point))))
          (goto-char pos))
      (end-of-line)))

    (defun ess-r-add-pipe ()
        "Add a pipe operator %>% at the end of the current line.
        Don't add one if the end of line already has one.  Ensure one
        space to the left and start a newline with indentation."
        (interactive)
        (end-of-line)
        (unless (looking-back "%>%" nil)
        (just-one-space 1)
        (insert "%>%"))
        (newline-and-indent)
        (evil-append nil))

    (defun ess-eval-pipe-through-line (vis)
      "Like `ess-eval-paragraph' but only evaluates up to the pipe on this line.
If no pipe, evaluate paragraph through the end of current line.
Prefix arg VIS toggles visibility of ess-code as for `ess-eval-region'."
      (interactive "P")
      (save-excursion
        (let ((end (progn
                     (ess-beginning-of-pipe-or-end-of-line)
                     (point)))
              (beg (progn (backward-paragraph)
                          (ess-skip-blanks-forward 'multiline)
                          (point))))
          (ess-eval-region beg end vis))))

    (defun inferior-ess-add-pipe ()
      "Like above but for inferior buffer."
      (interactive)
        (unless (looking-back "%>%" nil)
        (just-one-space 1)
        (insert "%>%")
        (just-one-space 1))
        (evil-append nil))

    (map! (:map ess-mode-map
           :i "C-<" #'ess-cycle-assign
           :i "C-." (λ! (insert "$") (+company/complete)))
          :niv "C-§" #'ess-switch-to-inferior-or-script-buffer
          :niv "C->" #'ess-r-add-pipe
          :map inferior-ess-mode-map
          :niv "C->" #'inferior-ess-add-pipe
          :niv "C-§" #'evil-window-next
          :nv "0" #'comint-bol
          :niv "C-r" #'counsel-shell-history
          :i "C-." (λ! (insert "$") (+company/complete))
          :localleader
          :map ess-mode-map
          "." #'ess-eval-pipe-through-line))
;;; Go
(after! go-mode
  (add-hook! 'go-mode-hook #'subword-mode)
  (setq flycheck-golangci-lint-enable-all nil
        ;; flycheck-golangci-lint-disable-linters '("gomodguard")
        ))

;;; Python
;; (set-formatter! 'autopep8 "autopep8 -")
(setq-hook! 'python-mode-hook
    py-isort-options '("--profile=black" "--multi-line=3")
    fill-column 88
    )

(defun python-before-save-hook ()
    (progn (py-isort-before-save))
)

(add-hook! 'python-mode-hook
    (add-hook 'before-save-hook #'python-before-save-hook nil t))

;; iedit
;; hack to fix conflict between pinned iedit/tree-sitter/python-mode
;; related issues:
;; 1. https://github.com/hlissner/evil-multiedit/issues/40
;; 2. https://github.com/ubolonton/emacs-tree-sitter/issues/73#issuecomment-739195967
;; 3. https://github.com/hlissner/evil-multiedit/issues/39
(add-hook! 'tree-sitter-after-on-hook
           (add-hook! 'iedit-mode-hook :local (tree-sitter-mode -1))
           (add-hook! 'iedit-mode-end-hook :local (tree-sitter-mode 1)))


;; appropriately chain flycheck chckers after lsp - credit to yyoncho:
;; https://github.com/flycheck/flycheck/issues/1762#issuecomment-750458442
(defvar-local +flycheck-local-cache nil)

(defun +flycheck-checker-get (fn checker property)
  (or (alist-get property (alist-get checker +flycheck-local-cache))
      (funcall fn checker property)))

(advice-add 'flycheck-checker-get :around '+flycheck-checker-get)

(add-hook 'lsp-managed-mode-hook
          (lambda ()
            (cond ((derived-mode-p 'python-mode)
                   (setq +flycheck-local-cache '((lsp . ((next-checkers . (python-flake8)))))))
                  ((derived-mode-p 'go-mode)
                   (setq +flycheck-local-cache '((lsp . ((next-checkers . (golangci-lint))))))))))

;;; Web Dev
;; web-mode
(defvar +html-engines '("none" "django"))
(set-formatter! 'prettier-html "prettier --parser html")
(defun +set-web-mode-formatter ()
  (if (and (equal web-mode-content-type "html")
           (member web-mode-engine +html-engines))
      (setq-local +format-with 'prettier-html)
    (setq-local +format-with 'prettier)))


(after! web-mode
  (setq web-mode-script-padding 0
        web-mode-code-indent-offset 2)
  (add-hook 'web-mode-local-vars-hook #'lsp!)
  (add-hook! 'web-mode-hook #'subword-mode
                            #'+set-web-mode-formatter))

;; dap-chrome
(after! web-mode
  (use-package! dap-chrome))

;;; Flycheck
(set-popup-rule! "^\\*Flycheck" :select t :side 'right :width 120 :slot 1)

;;; Format
(set-popup-rule! "^\\*format-all-errors*" :select nil :side 'bottom :height 15 :slot 1)

;;;
;;; Tree sitter
(use-package! tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

;;;
;;; LSP
(after! lsp-mode
  (dolist (dir '("[/\\\\]\\.venv\\'" "/src/relboost-engine\\'"))
    (push dir lsp-file-watch-ignored-directories))
  (setq lsp-signature-auto-activate t
        lsp-signature-render-documentation nil
        lsp-vetur-experimental-template-interpolation-service t)
        ;; lsp-pyright-python-executable-cmd "python")
  (lsp-register-custom-settings '(("vetur.validation.interpolation" nil nil))))

;; LSP and org
(defun org-babel-edit-prep:python (babel-info)
  "Prepare the local buffer environment for Org source block."
  (let ((lsp-file (or (->> babel-info caddr (alist-get :file))
                      buffer-file-name)))
    (setq-local buffer-file-name lsp-file)
    (setq-local lsp-buffer-uri (lsp--path-to-uri buffer-file-name))
    (lsp-python-enable)))

;; LSP dap
;; (use-package! dap-python)

;;; Org-mode setup

;; Poly Org
(use-package! poly-org)
(use-package! poly-markdown)

(defun +org-element-in-src-block-p (&optional inside)
  "A version of `org-in-src-block-p' that uses `org-element' for checking
if in src block to make it work with polymode (where char porpeties seem to
go lost)."
  (let ((case-fold-search t))
    (and (eq (org-element-type (org-element-context)) 'src-block)
         (if inside
             (save-match-data
               (save-excursion
                 (beginning-of-line)
                 (not (looking-at ".*#\\+\\(header\\|name\\|\\(begin\\|end\\)_src\\)"))))
           t))))

(defun polymode-mark-inner-chunk ()
  (let ((span (pm-innermost-span)))
    (set-mark (1+ (nth 1 span)))
    (goto-char (1- (nth 2 span)))))

(defun polymode-mark-chunk ()
  (let ((span (pm-innermost-span)))
    (goto-char (1- (nth 1 span)))
    (set-mark (line-beginning-position))
    (goto-char (nth 2 span))
    (goto-char (line-end-position))))

(evil-define-text-object evil-inner-polymode-chunk (count &optional beg end type)
  "Select inner polymode chunk."
  :type line
  (polymode-mark-inner-chunk)
  (evil-range (region-beginning)
              (region-end)
              'line))

(evil-define-text-object evil-a-polymode-chunk (count &optional beg end type)
  "Select a polymode chunk."
  :type line
  (polymode-mark-chunk)
  (evil-range (region-beginning)
              (region-end)
              'line))

(map! :map evil-inner-text-objects-map "c" 'evil-inner-polymode-chunk)
(map! :map evil-inner-text-objects-map "C" 'evilnc-inner-comment)
(map! :map evil-outer-text-objects-map "c" 'evil-a-polymode-chunk)
(map! :map evil-outer-text-objects-map "C" 'evilnc-outer-commenter)

(defun org-src-block-heading-or-org-previous-visible-heading ()
  (interactive)
  (if (+org-element-in-src-block-p t) (org-babel-goto-src-block-head)
    (org-babel-previous-src-block)))

;; (after! ivy
 ;; (add-to-list 'ivy-ignore-buffers "\\[.+\\]"))

;; (evil-define-minor-mode-key
;;   'normal 'poly-org-mode
;;   "C-c C-c" #'org-ctrl-c-ctrl-c)

(map! :map (poly-org-mode-map evil-org-mode-map)
      :niv "C-c C-c" #'org-ctrl-c-ctrl-c
      :nv "[i" #'polymode-previous-chunk
      :nv "]i" #'polymode-next-chunk
      :nv "C-i" #'better-jumper-jump-forward)

(map! :map (poly-org-mode-map evil-org-mode-map)
      :localleader
      "m" #'org-preview-latex-fragment)
;; :niv "C-c '" #'org-edit-special
(map! :after evil-org
      :map evil-org-mode-map
      :niv "C-i" #'better-jumper-jump-forward
      :i "C-l" (general-predicate-dispatch 'evil-delete-char
                 (org-at-table-p) 'org-table-next-field)
      :i "C-h" (general-predicate-dispatch 'delete-backward-char
                 (org-at-table-p) 'org-table-previous-field)
      :i "C-k" (general-predicate-dispatch 'evil-insert-digraph
                 (org-at-table-p) '+org/table-previous-row)
      :i "C-j" (general-predicate-dispatch 'electric-newline-and-maybe-indent
                 (org-at-table-p) 'org-table-next-row)
      :niv "C-c TAB" #'org-ctrl-c-tab
      :niv "C-c <C-tab>" (general-predicate-dispatch 'org-toggle-inline-images
                 (org-at-table-p) 'org-table-shrink)
      :nv "C-k" #'evil-insert-digraph
      :nv "C-j" #'electric-newline-and-maybe-indent)

(add-hook! 'polymode-init-inner-hook
  #'evil-normalize-keymaps)
     ;; lambda () (font-lock-add-keywords nil tex-font-lock-keywords-1))
     ;; lambda () (font-lock-add-keywords nil tex-font-lock-keywords-1))

;; General org-mode setup
;; Key bindings
(map! :after evil-org
      ;; :map (evil-org-mode-map poly-org-mode-map)
      ;; ;; Jumping with counsel
      ;; :desc "Jump: Heading" :nv "C-/ h" (λ! (counsel-org-goto))
      ;; :desc "Jump: SRC block" :nv "C-/ s" #'org-babel-goto-named-src-block
      ;; :desc "Jump: Imenu" :nv "C-/ i" #'counsel-imenu
      ;; Folding and zzzparse trees
      :desc "Sparse tree: SRC blocks" :nv "z s" (λ! (org-occur "^#\\+BEGIN_SRC"))
      :desc "Close all blocks" :nv "z B" #'org-hide-block-all
      :desc "Show all blocks" :nv "z b" #'org-show-block-all
      :nv "[c" #'org-src-block-heading-or-org-previous-visible-heading
      :niv "C-§" #'ess-switch-to-inferior-or-script-buffer
      ;; Set TAGS with counsel
      :niv "C-c C-q" #'counsel-org-tag
      :niv "C-c C-*" #'org-ctrl-c-star)

;; Let overlays persist revert buffer
(defun org-persistent-overlays ()
  "Congiguration of `persistent-overlays-minor-mode' in org buffers.
Featuers:
- Preserve overlays after `revert-buffer',
- Preserve overlays when activating `org-mode'."
  (setq-local persistent-overlays-auto-merge nil)
  (setq-local persistent-overlays-auto-load t)
  (persistent-overlays-minor-mode 1))
  ;; (add-hook! 'before-revert-hook #'persistent-overlays-save-overlays nil t)
  ;; (add-hook! 'after-revert-hook #'persistent-overlays-load-overlays nil t))

;; (add-hook! 'org-mode-hook #'org-persistent-overlays)

(after! org
  (use-package! ox-extra
    :config
    (ox-extras-activate '(ignore-headlines)))

  (org-link-set-parameters "marginnote3app"
                           :follow (lambda (path)
                                     (shell-command (concat "open marginnote3app:" path))))
  (setq org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9))
        org-outline-path-complete-in-steps nil ; Refile in a single go
        org-refile-use-outline-path t)
  (setq org-latex-create-formula-image-program 'dvisvgm
        org-ellipsis " ... " ; ▼
        org-latex-caption-above '(table))
  (setq-default org-format-latex-options (plist-put org-format-latex-options :scale 0.8))
  (setq org-babel-inline-result-wrap "%s")
  (setq org-latex-prefer-user-labels t)
  (set-popup-rule! "^\\*Org Src" :size 0.9 :quit nil :select t :autosave t :modeline t :ttl nil)
  (setq org-startup-indented nil)

  ;; Tufte
  (add-to-list 'org-latex-classes
               '("tufte-book"
                 "\\documentclass[round]{tufte-book}\n\\usepackage{color}\n\\usepackage{gensymb}\n\\usepackage{nicefrac}\n\\usepackage{units}"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


  ;; (add-hook 'org-mode-hook #'org-indent-mode)

  (defun org-babel-execute-named-src-block ()
    (interactive)
    (save-excursion
      (goto-char
       (org-babel-find-named-block
        (completing-read "Code Block: " (org-babel-src-block-names))))
      (org-babel-execute-src-block-maybe)))

  (defun +org/hide-block-subtree ()
  "Hide blocks only below current heading."
  (interactive)
  (save-restriction
    (widen)
    (org-narrow-to-subtree)
    (org-hide-block-all))))

(defun add-pcomplete-to-capf ()
  (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))

(add-hook 'org-mode-hook #'add-pcomplete-to-capf
          (set-company-backend! 'org-mode 'org-keyword-backend))

(defun markdown-convert-buffer-to-org ()
  "Convert the current buffer's content from markdown to orgmode format and save it with the current buffer's file name but with .org extension."
  (interactive)
  (shell-command-on-region point-min (point-max)
                           (format "pandoc -f markdown -t org -o %s"
                                   (concat (file-name-sans-extension (buffer-file-name)) ".org"))))

(defun org-keyword-backend (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'org-keyword-backend))
    (prefix (and (eq major-mode 'org-mode)
                 (cons (company-grab-line "^#\\+\\(\\w*\\)" 1)
                       t)))
    (candidates (mapcar #'upcase
                        (cl-remove-if-not
                         (lambda (c) (string-prefix-p arg c))
                         (pcomplete-completions))))
    (ignore-case t)
    (duplicates t)))

(defun markdown-convert-buffer-to-org ()
  "Convert the current buffer's content from markdown to orgmode format and save it with the current buffer's file name but with .org extension."
  (interactive)
  (shell-command-on-region point-min (point-max)
                           (format "pandoc -f markdown -t org -o %s"
                                   (concat (file-name-sans-extension (buffer-file-name)) ".org"))))

(setq org-latex-pdf-process
      '("latexmk -shell-escape -bibtex -pdf %f"))
(setq org-ref-default-bibliography '("~/Documents/Thesis/references_bibtex.bib")
      org-ref-bibliography-notes "~/Documents/Thesis/ref.org"
      org-ref-pdf-directory "~/Documents/Thesis/literature/"
      bibtex-completion-library-path "~/Documents/Thesis/literature/" ;the directory to store pdfs
      bibtex-completion-notes-path "~/Dropbox/org/ref.org" ;the note file for reference notes
      ;; org-directory "~/Dropbox/org"
      org-ref-bibliography-notes "~/Dropbox/org/ref.org"
      org-ref-default-citation-link "citet")

(map! :after org-ref
 (:map org-mode-map
      (:desc "References" :prefix "C-]"
      :i "C-c" #'org-ref-ivy-insert-cite-link
      :i "C-r" #'org-ref-ivy-insert-ref-link
      :i "C-l" #'org-ref-ivy-insert-label-link)))

;; AuCTeX setup
(setq-default TeX-master "preamble.tex")

;; writing
(use-package! academic-phrases
  :config
  (map! :after evil-org
        :map evil-org-mode-map
        :i "C-c [" #'academic-phrases-by-section))

(use-package! powerthesaurus
  :config
  (map! :after evil-org
        :map evil-org-mode-map
        :i "C-c '" #'powerthesaurus-lookup-word-dwim))
