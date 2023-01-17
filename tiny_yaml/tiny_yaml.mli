open! Base

module Accessor : sig
  include Tiny_config.Accessor.S with type config := Yaml.value
end

module Parser : sig
  include Tiny_config.Parser.S
end

module Converter : sig
  include
    Tiny_config.Converter.S
      with type 'a accessor := 'a Accessor.t
       and type ('a, 'b) parser := ('a, 'b) Parser.t
end

module Term : sig
  include Tiny_config.Term.S with type config := Yaml.value
end

module Value : sig
  include
    Tiny_config.Value.S
      with type ('a, 'b) converter := ('a, 'b) Converter.t
       and type 'a term := 'a Term.t
end
