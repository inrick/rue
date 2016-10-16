type t

exception Type_error

exception Nyi_error

exception Dim_error

val of_ints : int array -> t

val of_floats : float array -> t

val add : t -> t -> t

val sub : t -> t -> t

val mult : t -> t -> t

val div : t -> t -> t

val enum : t -> t

val rev : t -> t

val neg : t -> t

val show : t -> string
