defmodule Kic.SignUpsTest do
  use Kic.DataCase

  alias Kic.SignUps

  describe "sign_ups" do
    alias Kic.SignUps.SignUp

    test "it works" do
      res = SignUps.call()
      assert(res == "Hello")
    end

  end
end
