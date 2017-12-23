defmodule Web5280.FitbitControllerTest do
  use Web5280.ConnCase

  alias Web5280.Fitbit
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, fitbit_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing fitbits"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, fitbit_path(conn, :new)
    assert html_response(conn, 200) =~ "New fitbit"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, fitbit_path(conn, :create), fitbit: @valid_attrs
    assert redirected_to(conn) == fitbit_path(conn, :index)
    assert Repo.get_by(Fitbit, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, fitbit_path(conn, :create), fitbit: @invalid_attrs
    assert html_response(conn, 200) =~ "New fitbit"
  end

  test "shows chosen resource", %{conn: conn} do
    fitbit = Repo.insert! %Fitbit{}
    conn = get conn, fitbit_path(conn, :show, fitbit)
    assert html_response(conn, 200) =~ "Show fitbit"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, fitbit_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    fitbit = Repo.insert! %Fitbit{}
    conn = get conn, fitbit_path(conn, :edit, fitbit)
    assert html_response(conn, 200) =~ "Edit fitbit"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    fitbit = Repo.insert! %Fitbit{}
    conn = put conn, fitbit_path(conn, :update, fitbit), fitbit: @valid_attrs
    assert redirected_to(conn) == fitbit_path(conn, :show, fitbit)
    assert Repo.get_by(Fitbit, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    fitbit = Repo.insert! %Fitbit{}
    conn = put conn, fitbit_path(conn, :update, fitbit), fitbit: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit fitbit"
  end

  test "deletes chosen resource", %{conn: conn} do
    fitbit = Repo.insert! %Fitbit{}
    conn = delete conn, fitbit_path(conn, :delete, fitbit)
    assert redirected_to(conn) == fitbit_path(conn, :index)
    refute Repo.get(Fitbit, fitbit.id)
  end
end
