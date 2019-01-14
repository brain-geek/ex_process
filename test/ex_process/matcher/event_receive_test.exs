defmodule ExProcess.Matcher.EventReceiveTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  describe "ExProcess.Matcher.EventReceive.get_subscribe_data/1" do
    test "raises when unable to match" do
      assert_raise RuntimeError, "Unable to find corresponding matcher", fn ->
        ExProcess.Matcher.EventReceive.get_subscribe_data("Test unexistent matcher")
      end
    end

    test "matches string matches without conditions" do
      ExProcess.Matcher.EventReceive.register_matcher(
        "Case with condition",
        {:namespace, :topic}
      )

      assert(
        ExProcess.Matcher.EventReceive.get_subscribe_data("Case with condition") == [
          {"Case with condition", {:namespace, :topic}}
        ]
      )
    end

    test "matches regexp matches without conditions" do
      ExProcess.Matcher.EventReceive.register_matcher(
        ~r/Enable light switch (?<name>\w+)/,
        {:namespace, :topic}
      )

      assert(
        ExProcess.Matcher.EventReceive.get_subscribe_data("Enable light switch 34") == [
          {%{"name" => "34"}, {:namespace, :topic}}
        ]
      )
    end

    test "matches string matches with conditions" do
      test_func = fn x -> x === "test" end

      ExProcess.Matcher.EventReceive.register_matcher(
        "Case with condition",
        {:namespace, :topic},
        test_func
      )

      assert(
        ExProcess.Matcher.EventReceive.get_subscribe_data("Case with condition") == [
          {"Case with condition", {:namespace, :topic}, test_func}
        ]
      )
    end

    test "matches regexp matches with conditions" do
      test_func = fn x -> x === "test" end

      ExProcess.Matcher.EventReceive.register_matcher(
        ~r/Enable light switch (?<name>\w+)/,
        {:namespace, :topic},
        test_func
      )

      assert(
        ExProcess.Matcher.EventReceive.get_subscribe_data("Enable light switch 34") == [
          {%{"name" => "34"}, {:namespace, :topic}, test_func}
        ]
      )
    end
  end
end
