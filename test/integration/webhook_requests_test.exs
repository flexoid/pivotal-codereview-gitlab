defmodule PivotalCodereview.WebhookRequestsTest do
  use ExUnit.Case
  use Plug.Test

  alias PivotalCodereview.WebhookEndpoint

  @opts WebhookEndpoint.init([])
  @project_id 123
  @label_id 8123982132

  defp wait_for_children(supervisor, max_milliseconds \\ 2000)
  defp wait_for_children(_supervisor, 0), do: nil
  defp wait_for_children(supervisor, max_milliseconds) do
    case Supervisor.count_children(supervisor) do
      %{active: 0} ->
        nil
      _ ->
        Process.sleep(1)
        wait_for_children(supervisor, max_milliseconds - 1)
    end
  end

  setup do
    bypass = Bypass.open(port: 40028)
    ets_table = :ets.new(:bypass_control, [:set, :public])
    {:ok, bypass: bypass, ets_table: ets_table}
  end

  test "adds tag when merge request is opened", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "POST" == conn.method
      assert "/projects/#{@project_id}/stories/98765/labels" == conn.request_path

      {:ok, body, _conn} = Plug.Conn.read_body(conn)
      assert %{"name" => "on_code_review"} == Poison.decode!(body)

      response = Poison.encode!(%{
        "created_at" => "2017-03-31T21:48:29Z",
        "id" => @label_id,
        "kind" => "label",
        "name" => "on_code_review",
        "project_id" => @project_id,
        "updated_at" => "2017-03-31T21:48:29Z"
      })

      Plug.Conn.resp(conn, 200, response)
    end

    body = Poison.decode!(File.read!("test/fixtures/hook_mr_opened.json"))

    conn(:post, "/merge_request/#{@project_id}", Poison.encode!(body))
    |> put_req_header("content-type", "application/json")
    |> WebhookEndpoint.call(@opts)

    wait_for_children(PivotalCodereview.LabelActionSupervisor)
  end

  test "removes tag when merge request is merged", %{bypass: bypass, ets_table: ets_table} do
    Bypass.expect bypass, fn conn ->
      :ets.insert(ets_table, {"received_#{conn.method}", true})

      case conn.method do
        "GET" ->
          assert "/projects/123/stories/98765/labels" == conn.request_path

          response = Poison.encode!([
            %{"created_at" => "2016-08-08T17:48:42Z", "id" => 123123123112,
              "kind" => "label", "name" => "some_random_label",
              "project_id" => @project_id, "updated_at" => "2016-08-08T17:48:42Z"},
            %{"created_at" => "2016-11-15T12:56:08Z", "id" => @label_id,
              "kind" => "label", "name" => "on_code_review",
              "project_id" => @project_id, "updated_at" => "2016-11-15T12:56:08Z"}
          ])

          Plug.Conn.resp(conn, 200, response)

        "DELETE" ->
          assert "/projects/123/stories/98765/labels/#{@label_id}" == conn.request_path

          response = Poison.encode!(%{
            "created_at" => "2017-03-31T21:48:29Z",
            "id" => 555555,
            "kind" => "label",
            "name" => "on_code_review",
            "project_id" => 123,
            "updated_at" => "2017-03-31T21:48:29Z"
          })

          Plug.Conn.resp(conn, 200, response)
      end
    end

    body = Poison.decode!(File.read!("test/fixtures/hook_mr_merged.json"))

    conn(:post, "/merge_request/123", Poison.encode!(body))
    |> put_req_header("content-type", "application/json")
    |> WebhookEndpoint.call(@opts)

    wait_for_children(PivotalCodereview.LabelActionSupervisor)

    assert [{"received_GET", true}] == :ets.lookup(ets_table, "received_GET")
    assert [{"received_DELETE", true}] == :ets.lookup(ets_table, "received_DELETE")
  end

  test "removes tag when merge request is closed", %{bypass: bypass, ets_table: ets_table} do
    Bypass.expect bypass, fn conn ->
      :ets.insert(ets_table, {"received_#{conn.method}", true})

      case conn.method do
        "GET" ->
          assert "/projects/123/stories/98765/labels" == conn.request_path

          response = Poison.encode!([
            %{"created_at" => "2016-08-08T17:48:42Z", "id" => 123123123112,
              "kind" => "label", "name" => "some_random_label",
              "project_id" => @project_id, "updated_at" => "2016-08-08T17:48:42Z"},
            %{"created_at" => "2016-11-15T12:56:08Z", "id" => @label_id,
              "kind" => "label", "name" => "on_code_review",
              "project_id" => @project_id, "updated_at" => "2016-11-15T12:56:08Z"}
          ])

          Plug.Conn.resp(conn, 200, response)

        "DELETE" ->
          assert "/projects/123/stories/98765/labels/#{@label_id}" == conn.request_path

          response = Poison.encode!(%{
            "created_at" => "2017-03-31T21:48:29Z",
            "id" => 555555,
            "kind" => "label",
            "name" => "on_code_review",
            "project_id" => 123,
            "updated_at" => "2017-03-31T21:48:29Z"
          })

          Plug.Conn.resp(conn, 200, response)
      end
    end

    body = Poison.decode!(File.read!("test/fixtures/hook_mr_closed.json"))

    conn(:post, "/merge_request/123", Poison.encode!(body))
    |> put_req_header("content-type", "application/json")
    |> WebhookEndpoint.call(@opts)

    wait_for_children(PivotalCodereview.LabelActionSupervisor)

    assert [{"received_GET", true}] == :ets.lookup(ets_table, "received_GET")
    assert [{"received_DELETE", true}] == :ets.lookup(ets_table, "received_DELETE")
  end
end
