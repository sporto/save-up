defmodule Kic.Client do
  use Ecto.Schema
  import Ecto.Changeset


  schema "clients" do

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [])
    |> validate_required([])
  end
end
