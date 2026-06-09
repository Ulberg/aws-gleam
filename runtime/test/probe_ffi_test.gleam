import gleeunit/should

@external(erlang, "probe_ffi", "probe")
fn probe() -> BitArray

pub fn probe_ffi_compiles_test() {
  probe() |> should.equal(<<"ok">>)
}
