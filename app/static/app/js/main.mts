import * as d3 from "d3"

d3.select("#d3-entry").call($entry => {
    $entry.append("a").attr("href", "https://d3js.org/").text("D3")
    $entry.append("span").text(" because why not?")
})
