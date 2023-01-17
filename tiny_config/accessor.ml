open! Base
include Accessor_intf

module Make (M : Config) :
  Base with type config = M.config and type 'a t = M.config -> 'a = struct
  include M

  type 'a t = M.config -> 'a
end
