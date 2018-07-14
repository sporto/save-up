defmodule Kic.SignUps.CreateTest do
  use Kic.DataCase

  alias Kic.SignUps.Create

  describe "sign_ups" do

    test "it works" do
      res = Create.call()
      assert(res == "Hello")
    end

  end
end
