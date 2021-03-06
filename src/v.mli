(** Vector data structure exposing operations to combine vectors of compatible
  dimension and type. *)

type t

(** Domain error. *)
exception Domain_error

(** Type error. *)
exception Type_error

(** Not yet implemented error. *)
exception Nyi_error

(** Dimension error. *)
exception Dim_error

(** Convert one dimensional array of integers to a [t]. *)
val of_ints : int array -> t

(** Convert one dimensional array of floating point numbers to a [t]. *)
val of_floats : float array -> t

(** [add x y] adds [x] and [y] if they are of compatible dimension, otherwise
  raises [Dim_error]. *)
val add : t -> t -> t

(** [sub x y] subtracts [y] from [x] if they are of compatible dimension,
  otherwise raises [Dim_error]. *)
val sub : t -> t -> t

(** [mult x y] multiplies [x] and [y] if they are of compatible dimension,
  otherwise raises [Dim_error]. *)
val mult : t -> t -> t

(** [div x y] divides [x] by [y] if they are of compatible dimension, otherwise
  raises [Dim_error]. *)
val div : t -> t -> t

(** [enum n] creates a vector containing elements [0] to [n-1] if [n] is an
  integer, otherwise raises an error. *)
val enum : t -> t

(** [rev x] reverses [x]. *)
val rev : t -> t

(** [neg x] performs element-wise negation. *)
val neg : t -> t

(** [count x] returns the number of elements in [x]. *)
val count : t -> t

(** [take s x] creates new vector with shape [s] where elements are fetched
  cyclically from [x]. Raises [Dim_error] if [s] is not scalar or one
  dimensional. Raises [Type_error] if [s] is not an integer vector. *)
val take : t -> t -> t

(** [shape_of x] returns the shape of [x]. *)
val shape_of : t -> t

(** [show x] creates a printable string representation of [x]. *)
val show : t -> string
