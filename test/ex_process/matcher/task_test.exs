defmodule ExProcess.Matcher.TaskTest do
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
    ExProcess.Matcher.Task.register_matcher(~r/Enable light switch (?<name>\w+)/, ExProcess.TestMatcher)

    assert(
      ExProcess.Matcher.Task.take_all() ==
        MapSet.new([{~r/Enable light switch (?<name>\w+)/, ExProcess.TestMatcher}])
    )
  end

  describe "matching" do
    test "does not match when there's nothing to match" do
      assert(ExProcess.Matcher.Task.match("Kill Cthulhu") == {:error, "No matches found"})
    end

    test "matches string matchers" do
      ExProcess.Matcher.Task.register_matcher("Do stuff", ExProcess.TestMatcher)

      assert(ExProcess.Matcher.Task.match("Do stuff") == {:ok, [{"Do stuff", ExProcess.TestMatcher}]})
    end

    test "matches regexp matchers" do
      ExProcess.Matcher.Task.register_matcher(~r/Enable light switch (?<name>\w+)/, ExProcess.TestMatcher)

      assert(
        ExProcess.Matcher.Task.match("Enable light switch 6") ==
          {:ok, [{%{"name" => "6"}, ExProcess.TestMatcher}]}
      )
    end
  end

  describe "running matches" do
    test "runs the function matcher if it's available and singular" do
      ExProcess.Matcher.Task.register_matcher(
        ~r/Enable light switch (?<name>\w+)/,
        &TestHandler.run/1
      )

      assert(ExProcess.Matcher.Task.run_match("Enable light switch 555") == "Handled 555")
    end
  end
end
