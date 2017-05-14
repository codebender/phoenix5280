defmodule Fitbit.Utils do

  def delimit(number, precision) do
    Number.Delimit.number_to_delimited(number, precision: precision)
  end

  def display_date(date) do
    Date.from_iso8601!(date)
    |> Calendar.Strftime.strftime!("%B %e, %Y")
  end
end
