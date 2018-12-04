(require 'evil-arglist)
(require 'ert)

(ert-deftest evil-arglist-test-set-get ()
  (ert-info ("Setting/getting arglist")
    (let ((evil-arglist (list 1 2 3)))
      (should (eq evil-arglist (evil-arglist-get)))
      (set-window-parameter nil 'evil-arglist evil-arglist)
      (should (eq (window-parameter nil 'evil-arglist) (evil-arglist-get)))
      (set-window-parameter nil 'evil-arglist nil))
    (let ((evil-arglist nil))
      (evil-arglist-set (list 1 2 3) 2)
      (should (equal evil-arglist '(1 1 2 3)))
      (set-window-parameter nil 'evil-arglist (copy-sequence evil-arglist))
      (evil-arglist-set (list 3 2 1) 1)
      ;; Global arglist should be preserved if window local arglist is present
      (should (equal evil-arglist '(1 1 2 3)))
      (should (equal (window-parameter nil 'evil-arglist) '(2 3 2 1)))
      (set-window-parameter nil 'evil-arglist nil))))

(ert-deftest evil-arglist-test-do-edit ()
  (ert-info ("Setting the currently edited argument")
    (cl-letf (((symbol-function 'find-file) 'ignore))
      (let ((evil-arglist (list 0 2 3 1 5)))
        (evil-arglist-do-edit 1)
        (should (equal (car evil-arglist) 1))
        (evil-arglist-do-edit 2 'relative)
        (should (equal (car evil-arglist) 3))
        (should-error (evil-arglist-do-edit 10))
        (should-error (evil-arglist-do-edit -1))))))

(ert-deftest evil-arglist-test-add-args ()
  (let ((default-directory "")
        (evil-arglist (list 1 "./a" "./b")))
    (evil-arglist-add nil '("c" "d" "e"))
    (should (equal evil-arglist '(1 "./a" "./b" "./c" "./d" "./e")))
    (evil-arglist-add 2 '("f"))
    (should (equal evil-arglist '(1 "./a" "./b" "./f" "./c" "./d" "./e")))
    (evil-arglist-add 0 '("g"))
    (should (equal evil-arglist '(2 "./g" "./a" "./b" "./f" "./c" "./d" "./e")))))

(ert-deftest evil-arglist-test-delete-args ()
  (ert-info ("Deleting from the argument list")
    (let ((evil-arglist (list 0 "foo.c" "bar.d" "baz.el")))
      (evil-arglist-delete "*.c")
      (should (equal evil-arglist '(0 "bar.d" "baz.el")))
      (evil-arglist-set (cdr evil-arglist) "baz.el")
      (evil-arglist-delete "%")
      (should (equal evil-arglist '(1 "bar.d"))))))

(ert-deftest evil-arglist-test-motion ()
  (ert-info ("Moving around on the argument list")
    (cl-letf (((symbol-function 'find-file) 'ignore))
      (let ((evil-arglist (list 1 2 1 3 5)))
        (evil-arglist-rewind)
        (should (equal (car evil-arglist) 0))
        (should-error (evil-arglist-previous))
        (evil-arglist-next)
        (should (equal (car evil-arglist) 1))
        (evil-arglist-last)
        (should (equal (car evil-arglist) 3))
        (should-error (evil-arglist-next))
        (evil-arglist-previous)
        (should (equal (car evil-arglist) 2))
        (evil-arglist-argument 1)
        (equal (car evil-arglist) 0)))))
