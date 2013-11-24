#lang racket
(require "config.rkt")
(provide
  raw->user ;; Requires parsers as input
  user->raw
  user-username
  
  users

  symbol->users
  symbol->user
  string->users
  string->user
  write-users!)


;; Input module:

;; (list Symbol [List-of Extra-Field]) -> User
;; Given a username and list of extra fields, create a user
(define raw->user (make-parameter #f))

;; User -> (list Symbol [List-of Extra-Field] )
;; Given a user, creates a write-able representation of users
(define user->raw (make-parameter #f))

(define user-username (make-parameter #f))

;;------------------------------------------------------------------------ 

(define (users) 
  (let ([raw (with-input-from-file (path "users.rktd") read)])
    (map raw->user raw)))

;; Symbol -> [List-of User]
;; Given a Symbol of usernames seperated by #\+, return the list of
;; users 
(define (symbol->users s) (string->users (symbol->string s)))

(define (string->users s)
  (let ([usernames (map string->symbol (string-split s "+"))])
    (filter (lambda (user) (memq (user-username user) usernames)) (users))))

;; Assumes s represents a single username
(define (symbol->user s) (car (symbol->users s)))
(define (string->user s) (car (string->users s)))

;; [List-of User] -> Void
(define (write-users! ls)
  (with-output-to-file (path "users.rktd" )
                       (thunk (pretty-write (map user->raw ls)))
                       #:exists 'replace))
