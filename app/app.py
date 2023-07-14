import json
import datetime
import urllib.request
from statistics import mean
from typing import Any

from flask import Flask, render_template

WEATHER_URL = "https://api.open-meteo.com/v1/forecast?latitude=38.8951&longitude=-77.0364&hourly=temperature_2m,relativehumidity_2m,precipitation_probability&current_weather=true&temperature_unit=fahrenheit&windspeed_unit=mph&precipitation_unit=inch&timezone=America%2FNew_York&forecast_days=3"

WEATHER_CODES = {
    0: "clear skies",
    1: "mainly clear skies",
    2: "partly cloudy skies",
    3: "overcast skies",
    45: "fog",
    48: "depositing rime fog",
    51: "light drizzle",
    53: "moderate drizzle",
    55: "heavy drizzle",
    56: "light freezing drizzle",
    57: "heavy freezing drizzle",
    61: "light rain",
    63: "moderate rain",
    65: "heavy rain",
    66: "light freezing rain",
    67: "heavy freezing rain",
    71: "light snow",
    73: "moderate snow",
    75: "heavy snow",
    77: "snow grains",
    80: "light rain showers",
    81: "moderate rain showers",
    82: "heavy rain showers",
    85: "light snow showers",
    86: "heavy snow showers",
    95: "thunderstorms",
    96: "thunderstorms and slight hail",
    99: "thunderstorms and heavy hail",
}

"""
0 	Clear sky
1, 2, 3 	Mainly clear, partly cloudy, and overcast
45, 48 	Fog and depositing rime fog
51, 53, 55 	Drizzle: Light, moderate, and dense intensity
56, 57 	Freezing Drizzle: Light and dense intensity
61, 63, 65 	Rain: Slight, moderate and heavy intensity
66, 67 	Freezing Rain: Light and heavy intensity
71, 73, 75 	Snow fall: Slight, moderate, and heavy intensity
77 	Snow grains
80, 81, 82 	Rain showers: Slight, moderate, and violent
85, 86 	Snow showers slight and heavy
95 * 	Thunderstorm: Slight or moderate
96, 99 * 	Thunderstorm with slight and heavy hail
"""
app = Flask(__name__)


def convert_to_date(timestamp: str) -> str:
    day, _ = timestamp.split("T")
    return datetime.datetime.strptime(day, "%Y-%m-%d").strftime("%A, %B %-d")


def hour_to_time(hour: int) -> str:
    time_str = datetime.time(hour=hour).strftime("%I:00 %p")
    if time_str.startswith("0"):
        return time_str[1:]
    return time_str


def daily_high_low(temperatures) -> dict[str, str]:
    low, high = temperatures[0], temperatures[0]
    low_index, high_index = 0, 0
    for index, temp in enumerate(temperatures):
        if temp < low:
            low = temp
            low_index = index
        if temp > high:
            high = temp
            high_index = index
    return {
        "high": f"High of {high} degrees at approx. {hour_to_time(high_index)}.",
        "low": f"Low of {low} degrees at approx. {hour_to_time(low_index)}.",
    }


def _get_forecast() -> dict[str, Any]:
    resp = urllib.request.urlopen(WEATHER_URL)
    content = json.loads(resp.read())

    d1_temp = daily_high_low(content["hourly"]["temperature_2m"][0:24])
    d2_temp = daily_high_low(content["hourly"]["temperature_2m"][24:48])
    d3_temp = daily_high_low(content["hourly"]["temperature_2m"][48:72])

    d1_humidity = mean(content["hourly"]["relativehumidity_2m"][0:24])
    d2_humidity = mean(content["hourly"]["relativehumidity_2m"][24:48])
    d3_humidity = mean(content["hourly"]["relativehumidity_2m"][48:72])

    d1_precipitation = mean(content["hourly"]["precipitation_probability"][0:24])
    d2_precipitation = mean(content["hourly"]["precipitation_probability"][24:48])
    d3_precipitation = mean(content["hourly"]["precipitation_probability"][48:72])

    values = {
        "temperature": round(content["current_weather"]["temperature"]),
        "description": WEATHER_CODES.get(
            content["current_weather"]["weathercode"], "a total mystery"
        ),
        "day1": convert_to_date(content["hourly"]["time"][0]),
        "day2": convert_to_date(content["hourly"]["time"][24]),
        "day3": convert_to_date(content["hourly"]["time"][48]),
        "day1high": d1_temp["high"],
        "day1low": d1_temp["low"],
        "day1humidity": round(d1_humidity),
        "day1precipitation": round(d1_precipitation),
        "day2high": d2_temp["high"],
        "day2low": d2_temp["low"],
        "day2humidity": round(d2_humidity),
        "day2precipitation": round(d2_precipitation),
        "day3high": d3_temp["high"],
        "day3low": d3_temp["low"],
        "day3humidity": round(d3_humidity),
        "day3precipitation": round(d3_precipitation),
    }
    return values


@app.route("/")
def index() -> str:
    values = _get_forecast()
    return render_template("index.html", **values)


if __name__ == "__main__":
    app.run()
