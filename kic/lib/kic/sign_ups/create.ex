defmodule Kic.SignUps.Create do

  alias Kic.{Repo,Client,User}
  alias Comeonin.Pbkdf2

  def call(attr) do
    # client_changeset = Client.changeset(%Client{}, %{})
    { :ok, client } = Repo.insert(%Client{})

    # IO.inspect client.id

    %{ :password_hash => password_hash } = Pbkdf2
      .add_hash(attr[:password])

    # IO.inspect password_hash

    Repo.insert(%User{
      client_id: client.id,
      email: attr[:email],
      name: attr[:name],
      password_hash: password_hash,
      timezone: attr[:timezone],
    })
  end

end
