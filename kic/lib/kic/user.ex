defmodule Kic.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :client_id, :integer
    field :email, :string
    field :password_hash, :string
    field :name, :string
    field :timezone, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash, :timezone, :client_id])
    |> validate_required([:name, :email, :password_hash, :timezone, :client_id])
  end
end
