//// Unit tests for region resolution.

import aws/region.{NoRegion}
import gleam/dict
import gleeunit/should

fn env_from(
  pairs: List(#(String, String)),
) -> fn(String) -> Result(String, Nil) {
  let env = dict.from_list(pairs)
  fn(name: String) { dict.get(env, name) }
}

fn no_config() -> fn() -> Result(String, Nil) {
  fn() { Error(Nil) }
}

fn config_text(text: String) -> fn() -> Result(String, Nil) {
  fn() { Ok(text) }
}

pub fn resolves_from_aws_region_env_test() {
  region.resolve_with(
    profile: "default",
    env_lookup: env_from([#("AWS_REGION", "us-east-1")]),
    config_reader: no_config(),
  )
  |> should.equal(Ok("us-east-1"))
}

pub fn resolves_from_aws_default_region_when_aws_region_absent_test() {
  region.resolve_with(
    profile: "default",
    env_lookup: env_from([#("AWS_DEFAULT_REGION", "eu-north-1")]),
    config_reader: no_config(),
  )
  |> should.equal(Ok("eu-north-1"))
}

pub fn aws_region_wins_over_aws_default_region_test() {
  region.resolve_with(
    profile: "default",
    env_lookup: env_from([
      #("AWS_REGION", "us-east-1"),
      #("AWS_DEFAULT_REGION", "eu-north-1"),
    ]),
    config_reader: no_config(),
  )
  |> should.equal(Ok("us-east-1"))
}

pub fn empty_aws_region_is_skipped_test() {
  region.resolve_with(
    profile: "default",
    env_lookup: env_from([
      #("AWS_REGION", ""),
      #("AWS_DEFAULT_REGION", "eu-north-1"),
    ]),
    config_reader: no_config(),
  )
  |> should.equal(Ok("eu-north-1"))
}

pub fn falls_back_to_default_section_in_config_test() {
  region.resolve_with(
    profile: "default",
    env_lookup: env_from([]),
    config_reader: config_text("[default]\nregion = us-west-2\n"),
  )
  |> should.equal(Ok("us-west-2"))
}

pub fn falls_back_to_named_profile_section_in_config_test() {
  region.resolve_with(
    profile: "prod",
    env_lookup: env_from([]),
    config_reader: config_text(
      "[default]
region = us-east-1

[profile prod]
region = eu-north-1
",
    ),
  )
  |> should.equal(Ok("eu-north-1"))
}

pub fn env_wins_over_config_test() {
  region.resolve_with(
    profile: "default",
    env_lookup: env_from([#("AWS_REGION", "us-east-1")]),
    config_reader: config_text("[default]\nregion = should-be-ignored\n"),
  )
  |> should.equal(Ok("us-east-1"))
}

pub fn fails_with_no_region_when_nothing_set_test() {
  let assert Error(NoRegion(sources_tried: sources)) =
    region.resolve_with(
      profile: "default",
      env_lookup: env_from([]),
      config_reader: no_config(),
    )
  sources
  |> should.equal([
    "AWS_REGION",
    "AWS_DEFAULT_REGION",
    "~/.aws/config[profile=default].region",
  ])
}

pub fn malformed_config_is_treated_as_no_region_test() {
  let assert Error(NoRegion(_)) =
    region.resolve_with(
      profile: "default",
      env_lookup: env_from([]),
      config_reader: config_text("garbage = without-section"),
    )
  Nil
}

pub fn profile_section_missing_falls_through_test() {
  let assert Error(NoRegion(_)) =
    region.resolve_with(
      profile: "absent",
      env_lookup: env_from([]),
      config_reader: config_text("[default]\nregion = us-east-1\n"),
    )
  Nil
}
