defmodule ExProcess.Matcher.EventPublishTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  describe "get_publish_data/1" do
    test "raises when unable to match" do
      assert_raise RuntimeError, "Unable to find corresponding matcher", fn ->
        ExProcess.Matcher.EventPublish.get_publish_data("Test unexistent matcher")
      end
    end

    test "matches plain string matches" do
      ExProcess.Matcher.EventPublish.register_matcher(
        "Case with condition",
        {:namespace, :topic}
      )

      assert(
        ExProcess.Matcher.EventPublish.get_publish_data("Case with condition") == [
          {"Case with condition", {:namespace, :topic}}
        ]
      )
    end

    test "matches regexps" do
      ExProcess.Matcher.EventPublish.register_matcher(
        ~r/Enable light switch (?<name>\w+)/,
        {:namespace, :topic}
      )

      assert(
        ExProcess.Matcher.EventPublish.get_publish_data("Enable light switch 34") == [
          {%{"name" => "34"}, {:namespace, :topic}}
        ]
      )
    end

    test "works with multiple matches" do
      ExProcess.Matcher.EventPublish.register_matcher(
        ~r/Enable switch (in )?(?<name>[\w\s]+)/,
        {:ns, :t}
      )

      ExProcess.Matcher.EventPublish.register_matcher(
        "Enable switch in ventilation shaft",
        {:ns, :t2}
      )

      assert(
        ExProcess.Matcher.EventPublish.get_publish_data("Enable switch in ventilation shaft") == [
          {%{"name" => "ventilation shaft"}, {:ns, :t}},
          {"Enable switch in ventilation shaft", {:ns, :t2}}
        ]
      )
    end
  end

  describe "publish/1" do
    test "works with one string subscription" do
      ExProcess.Matcher.EventPublish.register_matcher("Publishme", :test_channel)
      ExProcess.PubSub.subscribe(self(), :test_channel)

      ExProcess.Matcher.EventPublish.publish("Publishme")

      assert_receive %ExProcess.PubSub.Message{channel: :test_channel, info: "Publishme"}
    end

    test "works with multiple subscriptions" do
      ExProcess.Matcher.EventPublish.register_matcher("Publishme 34", :test_channel)

      ExProcess.Matcher.EventPublish.register_matcher(
        ~r/Publishme (?<name>[\w\s]+)/,
        :other_channel
      )

      ExProcess.PubSub.subscribe(self(), :test_channel)
      ExProcess.PubSub.subscribe(self(), :other_channel)

      ExProcess.Matcher.EventPublish.publish("Publishme 34")

      assert_receive %ExProcess.PubSub.Message{channel: :test_channel, info: "Publishme 34"}
      assert_receive %ExProcess.PubSub.Message{channel: :other_channel, info: %{"name" => "34"}}
    end
  end
end
