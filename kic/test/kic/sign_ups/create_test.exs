defmodule Kic.SignUps.CreateTest do
  use Kic.DataCase

  alias Kic.SignUps.Create
  alias Kic.User

  describe "sign_ups" do

    test "it works" do
      attrs = %{
        name: "Sam",
        email: "sam@sample.com",
        password: "password",
        timezone: "Aus"
      }

      res = Create.call(attrs)

      assert {:ok, %User{} = user} = res
      assert user.name == attrs.name
      refute user.password_hash == attrs.password
    end

  end
end
