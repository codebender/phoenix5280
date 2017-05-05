defmodule Web5280.Fitbit.Utils do

  def parse_gender(gender) do
    gender = (gender || "")
    |> String.downcase

    case gender do
      "male"   -> :male
      "female" -> :female
      _        -> nil
    end
  end

  def parse_day(day) do
    day = (day || "")
    |> String.downcase

    case day do
      "sunday"    -> :sunday
      "monday"    -> :monday
      "tuesday"   -> :tuesday
      "wednesday" -> :wednesday
      "thursday"  -> :thursday
      "friday"    -> :friday
      "saturday"  -> :saturday
      _           -> nil
    end
  end

  def delimit(number, precision) do
    Number.Delimit.number_to_delimited(number, precision: precision)
  end

  def display_date(date) do
    Date.from_iso8601!(date)
    |> Calendar.Strftime.strftime!("%B %e, %Y")
  end
end
