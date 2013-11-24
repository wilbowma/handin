#lang scribble/doc
@(require "common.rkt")

@title{Interface}

This module provides a an interface to accessing and updating problem
sets and users. 

@defmodule[handin-server/interface]

@section{Problem set interface}

@defstruct[problem-set ([name string?] [dir path?] [start
exact-integer?] [end exact-integer?])]{

  A structure type for problem sets. name is a string naming both the
  problem set and the submission directory. dir is a absolute path to
  the submission directory. start and end are the start and end dates
  as seconds past midnight January 1, 1970 UTC.}

@defproc[(problem-sets) (listof problem-set?)]{

  Parses and return the problem sets from the current server
  configuration.}

@defproc[(write-problem-sets! [pss (listof problem-set?)]) void?]{

  Updates the server configuration with the given list of problem-sets,
  replacing any existing problem sets.}

@defproc[(gen-problem-sets [s exact-integer?] [n natural-number/c]
                           [#:prefix prefix string?])
         (listof problem-set?)]{

  Generates problem sets with dir (format "~a~a" prefix i) for i = 0
  to n. The first problem set will become active on the date s and
  remain active until exactly 7 days later.}

@section{User interface}

  Since users can have arbitrary extra fields, this interface is
  parameterized by the particular implementation of users. The parameters
  @racket[raw->user], @racket[user->raw], and @racket[user-username] need
  to be provided.

@defparam[raw->user f (-> (listof symbol? (listof any/c)) user?)]{

  Given a raw entry from users.rktd, return some representation of a
  user.}
  
@defparam[user->raw f (-> user? (listof symbol? (listof any/c)))]{
  
  Given a user, return a raw entry for users.rktd.}

@defparam[user-username f (-> user? symbol?)]{

  Given a user, return the username for that user.}

@defproc[(users) (listof user?)]{

  Parses and returns the user.rktd file.}

@defproc[(symbol->users [s symbol?]) (listof user?)]{

  Given a symbol of usernames seperated by #\+, return the list of
  users.}

@defproc[(string->users [s string?]) (listof user?)]{

  Given a string of usernames seperated by "+", return the list of
  users.}

@defproc[(symbol->user [s symbol?]) user?]{
  
  Given a symbol of a single username, return the corresponding user.}

@defproc[(string->user [s string?]) user?]{

  Given a string of a single username, return the corresponding user.}

@defproc[(write-users! [ls (listof user?)]) void?]{

  Replace users.rktd with the given list of users.  }
