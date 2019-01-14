defmodule ExProcess.PubSubTest do
  use ExUnit.Case

  setup do
    ExProcess.TestTools.reset_state()
  end

  test "raw subscription/publish" do
    ExProcess.PubSub.subscribe(self(), {:test, :testy})
    ExProcess.PubSub.broadcast({:test, :testy}, %{it: :works})

    assert_receive %ExProcess.PubSub.Message{channel: {:test, :testy}, info: %{it: :works}}
  end

  test "publish via matched string" do
    ExProcess.PubSub.subscribe(self(), {:test, :testy})
    ExProcess.Matcher.EventPublish.register_matcher("Yep, it works", {:test, :testy})

    ExProcess.PubSub.broadcast("Yep, it works")

    assert_receive %ExProcess.PubSub.Message{channel: {:test, :testy}, info: "Yep, it works"}
  end

  test "publish via regexp" do
    ExProcess.PubSub.subscribe(self(), {:test, :regexp})

    ExProcess.Matcher.EventPublish.register_matcher(~r/Enable (?<name>\w+) stuff/, {:test, :regexp})

    ExProcess.PubSub.broadcast("Enable some stuff")

    assert_receive %ExProcess.PubSub.Message{channel: {:test, :regexp}, info: %{"name" => "some"}}
  end

  test "publishing to multiple channels via same message" do
    ExProcess.PubSub.subscribe(self(), {:test, :channel1})
    ExProcess.PubSub.subscribe(self(), {:test, :channel2})

    ExProcess.Matcher.EventPublish.register_matcher(
      ~r/Get me something (?<name>\w+)/,
      {:test, :channel1}
    )

    ExProcess.Matcher.EventPublish.register_matcher("Get me something nice", {:test, :channel2})

    ExProcess.PubSub.broadcast("Get me something nice")
    assert_received %ExProcess.PubSub.Message{channel: {:test, :channel1}, info: %{"name" => "nice"}}

    assert_received %ExProcess.PubSub.Message{
      channel: {:test, :channel2},
      info: "Get me something nice"
    }
  end
end
