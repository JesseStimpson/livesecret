defmodule LiveSecret.Expiration do
  require Logger

  import Ecto.Query, only: [from: 2]

  alias LiveSecret.{Repo, Secret}

  def setup_job() do
    config = Application.fetch_env!(:livesecret, LiveSecret.Expiration)
    :timer.apply_interval(config[:interval], LiveSecret.Expiration, :expire, [])
  end

  def expire() do
    now = NaiveDateTime.utc_now()
    expire_before(now)
  end

  def expire_all() do
    expire_before(~N[2999-12-31 23:59:59.000])
  end

  def expire_before(now) do
    ids =
      from(s in Secret, where: s.expires_at < ^now, select: s.id)
      |> Repo.all()

    deleted =
      ids
      |> Enum.reduce(
        [],
        fn id, del_acc ->
          case Repo.delete(%Secret{id: id}) do
            {:ok, _} ->
              LiveSecret.PubSubDo.notify_expired(id)
              [id | del_acc]

            error ->
              Logger.error("EXPIRATION #{id} #{error}")
              del_acc
          end
        end
      )

    count_after = LiveSecret.Do.count_secrets()

    Logger.info(
      "EXPIRATION before #{inspect(now)} #{length(deleted)} deleted, #{count_after} remain"
    )
  end
end
