defmodule Kic.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :client_id, :string
    field :email, :string
    field :encrypted_password, :string
    field :name, :string
    field :timezone, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :encrypted_password, :timezone, :client_id])
    |> validate_required([:name, :email, :encrypted_password, :timezone, :client_id])
  end
end
