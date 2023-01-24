# Quick Start

A simple example of getting a single value, `threads` from a config file (in this case, a TOML file).

We use `Converter.Int.positive` to ensure that the value read from the config file is a positive value (strictly greater than zero).

While `tiny_toml` is used here, `tiny_yaml` works almost exactly the same.

- Replace `Tiny_toml` module with `Tiny_yaml`
- Replace the `Otoml.Parser.from_file` with an equivalent `Yaml` parsing code.  E.g., `Yaml.of_string @@ Stdio.In_channel.read_all name`
