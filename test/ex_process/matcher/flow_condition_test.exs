defmodule ExProcess.Matcher.FlowConditionTest do
  use ExUnit.Case

  defmodule TestHandler do
    def run(%{"name" => name}) do
      "Handled #{name}"
    end
  end

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "saves matchers" do
    ExProcess.Matcher.FlowCondition.register_matcher(
      ~r/Light switch (?<name>\w+) enabled/,
      ExProcess.TestMatcher
    )

    assert(
      ExProcess.Matcher.FlowCondition.take_all() ==
        MapSet.new([{~r/Light switch (?<name>\w+) enabled/, ExProcess.TestMatcher}])
    )
  end

  describe "matching" do
    test "does not match when there's nothing to match" do
      assert(
        ExProcess.Matcher.FlowCondition.match("Kill Cthulhu") ==
          {:error, {"No matches found", "Kill Cthulhu"}}
      )
    end

    test "matches string matchers" do
      ExProcess.Matcher.FlowCondition.register_matcher("Do stuff", ExProcess.TestMatcher)

      assert(
        ExProcess.Matcher.FlowCondition.match("Do stuff") ==
          {:ok, [{"Do stuff", ExProcess.TestMatcher}]}
      )
    end

    test "matches regexp matchers" do
      ExProcess.Matcher.FlowCondition.register_matcher(
        ~r/Enable light switch (?<name>\w+)/,
        ExProcess.TestMatcher
      )

      assert(
        ExProcess.Matcher.FlowCondition.match("Enable light switch 6") ==
          {:ok, [{%{"name" => "6"}, ExProcess.TestMatcher}]}
      )
    end
  end

  describe "running matches" do
    test "runs the function matcher if it's available and singular" do
      ExProcess.Matcher.FlowCondition.register_matcher(
        ~r/Light switch (?<name>\w+) enabled/,
        &TestHandler.run/1
      )

      assert(
        ExProcess.Matcher.FlowCondition.run_match("Light switch 555 enabled") == "Handled 555"
      )
    end
  end
end
