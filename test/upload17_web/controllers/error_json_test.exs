defmodule Upload17Web.ErrorJSONTest do
  use Upload17Web.ConnCase, async: true

  test "renders 404" do
    assert Upload17Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Upload17Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
