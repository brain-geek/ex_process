defmodule ExProcessTest do
  use ExUnit.Case
  doctest ExProcess

  test "when wrong xml passed" do
    assert(
      ExProcess.run(~s(<?xml version="1.0" encoding="UTF-8"?><a></a>)) ==
        {:error, "Unable to find process element"}
    )
  end
end
