### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ db4c1f10-7c37-4513-887a-2467ce673458
begin
	using CSV
	using DataFrames
	using PlutoUI
	using Shapefile
	using ZipFile
	using LsqFit
	using Plots
end

# ╔═╡ cbd9c1aa-fc37-11ea-29d9-e3361406796f
using Dates

# ╔═╡ d3398953-afee-4989-932c-995c3ffc0c40
md"""
# Exploring data: COVID-19 epidemic
"""

# ╔═╡ efa281da-cef9-41bc-923e-625140ce5a07
md"""
In this notebook we will explore and analyse some data on the COVID-19 pandemic. The aim is to use Julia tools to analyse and visualise the data in different ways.

By the end of the notebook we will produce the following visualisation using Julia and Pluto:
"""

# ╔═╡ 7617d970-fce4-11ea-08ba-c7eba3e17f62
@bind day Clock(0.5)

# ╔═╡ e0493940-8aa7-4733-af72-cd6bc0e37d92
md"""
## Download and load data
"""

# ╔═╡ 64d9bcea-7c85-421d-8f1e-17ea8ee694da
url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv";

# ╔═╡ c460b0c3-6d3b-439b-8cc7-1c58d6547f51
download(url, "covid_data.csv");

# ╔═╡ a7369222-fc20-11ea-314d-4d6b0f0f72eb
md"We will need a couple of new packages. The data is in CSV format, i.e. *C*omma-*S*eparated *V*alues. This is a common data format in which observations, i.e. data points, are separated on different lines. Within each line the different data for that observation are separated by commas or other punctuation (possibly spaces and tabs)."

# ╔═╡ 1620aa9d-7dcd-4686-b7e4-a72cebe315ed
md"""
We can load the data from a CSV using the `File` function from the `CSV.jl` package, and then convert it to a `DataFrame`:
"""

# ╔═╡ 38344160-fc27-11ea-220e-95aa00e4b083
begin
	csv_data = CSV.File("covid_data.csv");   
	data = DataFrame(csv_data)   # it is common to use `df` [dataframe] as a variable name
end

# ╔═╡ 656aa2f1-95d4-45a1-b129-4271ecc14ac2
f = CSV.File("covid_data.csv")

# ╔═╡ 2039f5c4-fe54-4808-9414-be29214123ef
typeof(f)

# ╔═╡ 5f107c98-3514-44e7-be14-14b3806333db


# ╔═╡ ad43cea2-fc28-11ea-2bc3-a9d81e3766f4
md"A `DataFrame` is a standard way of storing **heterogeneous data** in Julia, i.e. a table consisting of columns with different types. As you can see from the display of the `DataFrame` object above, each column has an associated type, but different columns have different types, reflecting the type of the data in that column.

In our case, country names are stored as `String`s, their latitude and longitude as `Float64`s and the (cumulative) case counts for each day as `Int64`s.
."

# ╔═╡ fab64d86-fc28-11ea-0ae1-3ba1b9a14759
md"## Using the data"

# ╔═╡ 3519cf96-fc26-11ea-3386-d97c61ea1b85
md"""Since we need to manipulate the columns, let's rename them to something shorter. We can do this either **in place**, i.e. modifying the original `DataFrame`, or **out of place**, creating a new `DataFrame`. The convention in Julia is that functions that modify their argument have a name ending with `!` (often pronounced "bang").

We can use the `head` function to see only the first few lines of the data.
"""

# ╔═╡ ecb8098a-ceda-4739-aa8b-0ed72feccf4a


# ╔═╡ a054e048-4fea-487c-9d06-463723c7151c
begin
	data_2 = rename(data, 1 => "province", 2 => "country", 3 => "latitude", 4 => "longitude")   
	first(data_2, 5)
end

# ╔═╡ 4e30a9de-6b42-4d8d-a910-8e2999f6f52f
p =    1 => "province"   # don't confuse with x -> 2x

# ╔═╡ 283c8030-3683-4f73-aae2-9f01afca4194
typeof(p)

# ╔═╡ afc82e07-95e6-48cf-97a4-c88ebd4847d4
d = Dict("a" => 1, "b" => 2)

# ╔═╡ e9ad97b6-fdef-4f48-bd32-634cfd2ce0e6
begin
	rename!(data, 1 => "province", 2 => "country", 3 => "latitude", 4 => "longitude") 
	first(data, 5)
end

# ╔═╡ ea444f4b-1524-4794-ae0a-bf75aac36749
data

# ╔═╡ 795daf44-bce2-478e-a7eb-2ae4811e32f4
missing

# ╔═╡ e31c3de7-5afa-4e82-84a1-db6b1fb22e9f
typeof(missing)

# ╔═╡ fcd29e73-a154-43de-8534-d36bd7537c29
data.latitude

# ╔═╡ a021c58d-0959-4de4-820f-619a367a69a8
collect(skipmissing(data.latitude))

# ╔═╡ 136e7560-55c8-4619-9c95-1a47cf66a58d
length(data.latitude)

# ╔═╡ 58ae2194-4e47-468d-9ee8-043537ceccab
length(collect(skipmissing(data.latitude)))

# ╔═╡ 46750c6d-4709-4589-b54c-7f86872db408


# ╔═╡ aaa7c012-fc1f-11ea-3c6c-89630affb1db
md"## Extracting useful information"

# ╔═╡ b0eb3918-fc1f-11ea-238b-7f5d23e424bb
md"How can we extract the list of all the countries? The country names are in the second column.

For some purposes we can think of a `DataFrame`.as a matrix and use similar syntax. For example, we can extract the second column:
"

# ╔═╡ 68f76d3b-b398-459d-bf39-20bf300dcaa2
all_countries = data[:, "country"]

# ╔═╡ 4668e229-548a-4391-a72d-230241b52bf7


# ╔═╡ b1ad1c7a-0baf-459a-93c9-62b268643a77
data[:, :country]

# ╔═╡ 1e93c85d-8c8c-449f-ae1d-01689ac1df74


# ╔═╡ 20e144f2-fcfb-11ea-010c-97e21eb0d231
all_countries2 = data[:, :country]

# ╔═╡ 2ec98a16-fcfb-11ea-21ad-15f2f5e68248
all_countries3 = data[:, 2]

# ╔═╡ 382cfc62-fcfb-11ea-26aa-2984d0449dcc
data[5:8, 2]

# ╔═╡ 34440afc-fc2e-11ea-0484-5b47af235bad
md"It turns out that some countries are divided into provinces, so there are repetitions in the `country` column that we can eliminate with the `unique` function:"

# ╔═╡ 79ba0433-2a31-475a-87c9-14103ebbff16
countries = unique(all_countries)

# ╔═╡ c72e3142-75c4-4ece-8f08-cbadda6ad4d1
num_countries = length(countries)

# ╔═╡ 5c1ec9ae-fc2e-11ea-397d-937c7ab1edb2
@bind i Slider(1:length(countries), show_value=true)

# ╔═╡ a39589ee-20e3-4f22-bf81-167fd815f6f9
md"""
$(Text(countries[i]))
"""

# ╔═╡ b7e1b68a-e04c-44d5-9f8d-d18b9afa51ab
countries[i]

# ╔═╡ 9484ea9e-fc2e-11ea-137c-6da8212da5bd
md"[Here we used **string interpolation** with `$` to put the text into a Markdown string.]"

# ╔═╡ bcc95a8a-fc2e-11ea-2ccd-3bece42a08e6
md"You can also use `Select` to get a dropdown instead:"

# ╔═╡ ada3ceb4-fc2e-11ea-2cbf-399430fa18b5
@bind country Select(countries)

# ╔═╡ 1633abe8-fc2f-11ea-2c7e-21b3348a3569
md"""How can we extract the data for a particular country? First we need to know the exact name of the country. E.g. is the US written as "USA", or "United States"?

We could scroll through to find out, or **filter** the data to only look at a sample of it, for example those countries that begin with the letter "U".

One way to do this is with an array comprehension:"""

# ╔═╡ ed383524-e0c0-4da2-9a98-ca75aadd2c9e
md"""
Array comprehension:
"""

# ╔═╡ 90810d7e-fcfb-11ea-396a-35543dcc1e06
startswith("david", "d")

# ╔═╡ 977e1a2c-fcfb-11ea-08e9-cd656a631778
startswith("hello", "d")

# ╔═╡ 9ee79840-30ff-4c92-97f4-e178caceceaf
U_countries = [startswith(country, "U") for country in all_countries]

# ╔═╡ b3f7035f-2653-4a1d-8efc-532ce1bf1e19
startswith.(all_countries, "U")

# ╔═╡ 99d5a138-fc30-11ea-2977-71732ca3aead
length(U_countries)

# ╔═╡ 450b4902-fc30-11ea-321d-29faf6188ff5
md"Note that this returns an array of booleans of the same length as the vector `all_countries`. We can now use this to index into the `DataFrame`:"

# ╔═╡ 4f423a75-43da-486f-ac2a-7220032dac9f
data[U_countries, :]

# ╔═╡ a8b2db96-fc30-11ea-2eea-b938a3a430fb
md"""We see that the correct spelling is `"US"`. (And note how the different provinces of the UK are separated.)"""

# ╔═╡ c400ce4e-fc30-11ea-13b1-b54cf8f5630e
md"Now we would like to extract the data for the US alone. How can we access the correct row of the table? We can again filter on the country name. A nicer way to do this is to use the `filter` function.

This is a **higher-order function**: its first argument is itself a function, which must return `true` or `false`.  `filter` will return all the rows of the `DataFrame` that satisfy that **predicate**:
"

# ╔═╡ 7b2496b0-fc35-11ea-0e78-473e5e8eac44
filter(x -> x.country == "United Kingdom", data)

# ╔═╡ 8990f13a-fc35-11ea-338f-0955eeb23c3c
md"Here we have used an **anonymous function** with the syntax `x -> ⋯`. This is a function which takes the argument `x` and returns whatever is on the right of the arrow (`->`)."

# ╔═╡ a772eadc-fc35-11ea-3d38-4b121f88f1d7
md"To extract a single row we need the **index** of the row (i.e. which number row it is in the `DataFrame`). The `findfirst` function finds the first row that satisfies the given predicate:"

# ╔═╡ 16a79308-fc36-11ea-16e5-e1087d7ebbda
US_row = findfirst(==("US"), all_countries)

# ╔═╡ a41db8ea-f0e0-461f-a298-bdcea42a67f3
data[US_row, :]

# ╔═╡ 50cc0714-c73a-4622-8b09-6c9e8662637a
typeof(data[US_row, :])

# ╔═╡ e540e990-06b0-4a25-aca8-5d35b5ebac50
typeof(data[256, :])

# ╔═╡ fb756077-791e-424c-844e-523b44fe3bdc
data[3:4, :]

# ╔═╡ f75e1992-fcfb-11ea-1123-b59bf888eac3
data[US_row:US_row, :]

# ╔═╡ 67eebb7e-fc36-11ea-03ef-bd6966487bb5
md"Now we can extract the data into a standard Julia `Vector`:"

# ╔═╡ 7b5db0f4-fc36-11ea-09a5-49def64f4c79
US_data = Vector(data[US_row, 5:end])

# ╔═╡ f099424c-0e22-42fb-894c-d8c2a65715fb
scatter(US_data, 
		m=:o, alpha=0.2, ms=2, 
		xlabel="day", ylabel="cumulative cases", 
		leg=false)

# ╔═╡ 7e7d14a2-fc37-11ea-3f1a-870ca98c4b75
md"Note that we are only passing a single vector to the `scatter` function, so the $x$ coordinates are taken as the natural numbers $1$, $2$, etc.

Also note that the $y$-axis in this plot gives the *cumulative* case numbers, i.e. the *total* number of confirmed cases since the start of the epidemic up to the given date. 
"

# ╔═╡ 75d2dc66-fc47-11ea-0e35-05f9cf38e901
md"This is an example of a **time series**, i.e. a single quantity that changes over time."

# ╔═╡ b3880f40-fc36-11ea-074a-edc51adeb6f0
md"## Using dates"

# ╔═╡ 6de0800c-fc37-11ea-0d94-2b6f8f66964d
md"We would like to use actual dates instead of just the number of days since the start of the recorded data. The dates are given in the column names of the `DataFrame`:
"

# ╔═╡ bb6316b7-23fb-44a3-b64a-dfb71a7df011
column_names = names(data)

# ╔═╡ 0c098923-b016-4c65-9a37-6b7b56b13a0c
date_strings = names(data)[5:end]  # apply String function to each element

# ╔═╡ 546a40eb-7897-485d-a1b5-c4dfae0a4861
md"""
Now we need to **parse** the date strings, i.e. convert from a string representation into an actual Julia type provided by the `Dates.jl` standard library package:
"""

# ╔═╡ 9e23b0e2-ac13-4d19-a3f9-4a655a1e9f14
date_strings[1]

# ╔═╡ 25c79620-14f4-45a7-b120-05ec72cb77e9
date_format = Dates.DateFormat("m/d/Y")

# ╔═╡ 9c123e2c-6cb7-4bcd-9f0f-fe06c809754b
parse(Int, "35")

# ╔═╡ 9807da0c-4344-450d-a8c1-b5dd64c39974
parse(Float64, "35")

# ╔═╡ 4d434bca-7fce-4c81-9532-b28b4763a82f
parse(Int64, "3.1")

# ╔═╡ 31dc4e46-4839-4f01-b383-1a1189aeb0e6
my_date = parse(Date, date_strings[1], date_format)

# ╔═╡ 34af7dc4-8ec9-4268-afb8-7f5ec7cd8e12
my_date.instant

# ╔═╡ 9de44d78-5de2-4817-910b-14bb3442719f
year(my_date)

# ╔═╡ 7467913a-ee1c-4c39-81fa-e277598d1725
month(my_date)

# ╔═╡ ee27bd98-fc37-11ea-163c-1365e194fc2e
md"Since the year was not correctly represented in the original data, we need to manually fix it:"

# ╔═╡ f5c29f0d-937f-4731-8f87-0405ebc966f5
dates = parse.(Date, date_strings, date_format) .+ Year(2000)

# ╔═╡ b0e7f1c6-fce3-11ea-10e5-9101d0f861a2
dates[day]

# ╔═╡ 36c37b4d-eb23-4deb-a593-e511eccd9204
begin
	plot(dates, US_data,  leg=:topleft, 
	    label="US data", m=:o, ms=3, alpha=0.5, xrotation=60)
	
	xlabel!("date")
	ylabel!("cumulative US cases")
	title!("US cumulative confirmed COVID-19 cases")
end

# ╔═╡ 443f876c-658b-45d2-8953-5f5cbc1c0a14
plot(US_data, dates)

# ╔═╡ 5f304eb2-f495-4b63-8d25-faa5a35af78a
function ff(x, y; a=1, b=2)
	return x - y + a + b
end

# ╔═╡ 6c2b6f2a-5a3d-481d-8f78-58bdf450e3a8
ff(1, 2)

# ╔═╡ 5716677a-14fe-468d-9594-292f8f102bf0
ff(2, 1)

# ╔═╡ b01c053c-7199-4290-8870-57e2a8c91d09
ff(2, 1, a=3)

# ╔═╡ 4d9228c2-6ce8-47d9-8ac4-1d6251e1c6f1
ff(2, 1, b=4)

# ╔═╡ e07cafab-327f-4bed-a210-e8467747846f
ff(2, 1, a=3, b=4)

# ╔═╡ 52b494fc-e3f8-4248-b808-1c9cd0ab9cde
ff(2, 1, b=4, a=3)

# ╔═╡ 511eb51e-fc38-11ea-0492-19532da809de
md"## Exploratory data analysis"

# ╔═╡ d228e232-fc39-11ea-1569-a31b817118c4
md"
Working with *cumulative* data is often less intuitive. Let's look at the actual number of daily cases. Julia has a `diff` function to calculate the difference between successive entries of a vector:
"

# ╔═╡ dbaacbb6-fc3b-11ea-0a42-a9792e8a6c4c
begin
	daily_cases = diff(US_data)
	plot(dates[2:end], daily_cases, m=:o, leg=false, xlabel="days", ylabel="daily US cases", alpha=0.5)   # use "o"-shaped markers
end

# ╔═╡ 19bdf146-fc3c-11ea-3c60-bf7823c43a1d
begin
	using Statistics
	running_mean = [mean(daily_cases[i-6:i]) for i in 7:length(daily_cases)]
end

# ╔═╡ 12900562-fc3a-11ea-25e1-f7c91a6940e5
md"Note that discrete data should *always* be plotted with points. The lines are just to guide the eye. 

Cumulating data corresponds to taking the integral of a function and is a *smoothing* operation. Note that the cumulative data is indeed visually smoother than the daily data.

The oscillations in the daily data seem to be due to a lower incidence of reporting at weekends. We could try to smooth this out by taking a **moving average**, say over the past week:
"

# ╔═╡ be868a52-fc3b-11ea-0b60-7fea05ffe8e9
begin
	plot(daily_cases, label="raw daily cases")
	plot!(running_mean, m=:o, label="running weakly mean", leg=:topleft)
end

# ╔═╡ 0b01120c-fc3d-11ea-1381-8bab939e6214
md"## Exponential growth

Simple models of epidemic spread often predict a period with **exponential growth**. Do the data corroborate this?
"

# ╔═╡ 252eff18-fc3d-11ea-0c18-7b130ada882e
md"""A visual check for this is to plot the data with a **logarithmic scale** on the $y$ axis (but a standard scale on the $x$ axis).

If we observe a straight line on such a semi-logarithmic plot, then we know that

$$\log(y) \sim \alpha x + \beta,$$

where we are using $\sim$ to denote approximate equality.

Taking exponentials of both sides gives

$$y \sim \exp(\alpha x + \beta),$$

i.e.

$$y \sim c \, \mathrm{e}^{\alpha x},$$

where $c$ is a constant (sometimes called a "pre-factor") and $\alpha$ is the exponential growth rate, found from the slope of the straight line on the semi-log plot.
"""

# ╔═╡ 9626d74a-fc3d-11ea-2ab3-978dc46c0f1f
md"""Since the data contains some zeros, we need to replace those with `NaN`s ("Not a Number"), which `Plots.jl` interprets as a signal to break the line"""

# ╔═╡ 4af67287-b97c-4c25-9a17-088eda346b6f
v = [1, 2, 3, 2]

# ╔═╡ ecd64c32-6baa-496d-bc1a-21fe4c561e5a
replace(v, 2 => 10)

# ╔═╡ 4358c348-91aa-4c76-a443-0a9cefce0e83
begin
	plot(replace(daily_cases, 0 => NaN), 
		yscale=:log10, 
		leg=false, m=:o)
	
	xlabel!("day")
	ylabel!("confirmed cases in US")
	title!("US confirmed COVID-19 cases")
end

# ╔═╡ fd5848a9-4fa8-4b6b-8ad9-05173d422273
begin
	plot(daily_cases,   # Not A Number
		yscale=:log10, 
		leg=false, m=:o, ylims=(0, 10))
	
	xlabel!("day")
	ylabel!("confirmed cases in US")
	title!("US confirmed COVID-19 cases")
end

# ╔═╡ ef953d4a-4375-497e-9829-0498c5083c00
0.0 / 0.0

# ╔═╡ 687409a2-fc43-11ea-03e0-d9a7a48165a8
md"Let's zoom in on the region of the graph where the growth looks linear on this semi-log plot:"

# ╔═╡ 4f23c8fc-fc43-11ea-0e73-e5f89d14155c
xlims!(0, 100)

# ╔═╡ b0e0d7fc-c77e-495d-a800-3f53a1ab2e51
plotly()

# ╔═╡ c85b20fb-c2a0-43d3-ae8d-bbe897667dfe
begin
	plot(daily_cases,   # Not A Number
		yscale=:log10, 
		leg=false, m=:o, ylims=(0, 10))
	
	xlabel!("day")
	ylabel!("confirmed cases in US")
	title!("US confirmed COVID-19 cases")
end

# ╔═╡ 91f99062-fc43-11ea-1b0e-afe8aa8a1c3d
exp_period = 38:60

# ╔═╡ 07282688-fc3e-11ea-2f9e-5b0581061e65
md"We see that there is a period lasting from around day $(first(exp_period)) to around day $(last(exp_period)) when the curve looks straight on the semi-log plot. 
This corresponds to the following date range:"

# ╔═╡ 210cee94-fc3e-11ea-1a6e-7f88270354e1
dates[exp_period]

# ╔═╡ 2f254a9e-fc3e-11ea-2c02-75ed59f41903
md"i.e. the first 3 weeks of March. Fortunately the imposition of lockdown during the last 10 days of March (on different days in different US states) significantly reduced transmission."

# ╔═╡ 84f5c776-fce0-11ea-2d52-39c51d4ab6b5
md"## Data fitting"

# ╔═╡ 539c951c-fc48-11ea-2293-457b7717ea4d
md"""Let's try to fit an exponential function to our data in the relevant region. We will use the Julia package `LsqFit.jl` ("least-squares fit").

This package allows us to specify a model function that takes a vector of data and a vector of parameters, and it finds the best fit to the data.
"""

# ╔═╡ b33e97f2-fce0-11ea-2b4d-ffd7ed7000f8
model(x, (c, α)) = c .* exp.(α .* x)

# ╔═╡ d52fc8fe-fce0-11ea-0a04-b146ee2dbe80
begin
	p0 = [0.5, 0.5]  # initial guess for parameters

	x_data = exp_period
	y_data = daily_cases[exp_period]
	
	fit = curve_fit(model, x_data, y_data, p0)
end;

# ╔═╡ c50b5e42-fce1-11ea-1667-91c56ea80dcc
md"We are interested in the coefficients of the best-fitting model:"

# ╔═╡ 3060bfa8-fce1-11ea-1047-db0dc06485a2
parameters = coef(fit)

# ╔═╡ 62bdc04a-fce1-11ea-1724-bfc4bc4789d1
md"Now let's add this to the plot:"

# ╔═╡ 6bc8cc20-fce1-11ea-2180-0fa69e86741f
begin
	plot(replace(daily_cases, 0 => NaN), 
		yscale=:log10, 
		leg=false, m=:o,
		xlims=(1, 100), alpha=0.5)
	
	line_range = 30:70
	plot!(line_range, model(line_range, parameters), lw=3, ls=:dash, alpha=0.7)
	
	xlabel!("day")
	ylabel!("confirmed cases in US")
	title!("US confirmed COVID-19 cases")
end

# ╔═╡ 287f0fa8-fc44-11ea-2788-9f3ac4ee6d2b
md"## Geographical data"

# ╔═╡ 3edd2a22-fc4a-11ea-07e5-55ca6d7639e8
md"Our data set contains more information: the geographical locations (latitude and longitude) of each country (or, rather, of a particular point that was chosen as being representative of that country)."

# ╔═╡ c5ad4d40-fc57-11ea-23cb-e55487bc6f7a
filter(x -> startswith(x.country, "A"), data)

# ╔═╡ 57a9bb06-fc4a-11ea-2665-7f97026981dc
md"Let's extract and plot the geographical information. To reduce the visual noise a bit we will only use those "

# ╔═╡ 80138b30-fc4a-11ea-0e15-b54cf6b402df
province = data.province

# ╔═╡ 8709f208-fc4a-11ea-0203-e13eae5f0d93
md"If the `province` is missing we should use the country name instead:"

# ╔═╡ a29c8ad0-fc4a-11ea-14c7-71435769b73e
begin
	indices = ismissing.(province)
	province[indices] .= all_countries[indices]
end

# ╔═╡ 4e4cca22-fc4c-11ea-12ae-2b51545799ec
begin 
	
	scatter(data.longitude, data.latitude, leg=false, alpha=0.5, ms=2)

	for i in 1:length(province)	
		annotate!(data.longitude[i], data.latitude[i], text(province[i], :center, 5, color=RGBA{Float64}(0.0,0.0,0.0,0.3)))
	end
	
	plot!(axis=false)
end

# ╔═╡ 16981da0-fc4d-11ea-37a2-535aa014a298
data.latitude

# ╔═╡ a9c39dbe-fc4d-11ea-2e86-4992896e2abb
md"## Adding maps"

# ╔═╡ b93b88b0-fc4d-11ea-0c45-8f64983f8b5c
md"We would also like to see the outlines of each country. For this we can use, for example, the data from [Natural Earth](https://www.naturalearthdata.com/downloads/110m-cultural-vectors/110m-admin-0-countries), which comes in the form of **shape files**, giving the outlines in terms of latitude and longitude coordinates. 

These may be read in using the `Shapefile.jl` package.

The data is provided in a `.zip` file, so after downloading it we first need to decompress it.
"

# ╔═╡ 7ec28cd0-fc87-11ea-2de5-1959ea5dc37c
begin
	zipfile = download("https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_countries.zip")

	r = ZipFile.Reader(zipfile);
	for f in r.files
	    println("Filename: $(f.name)")
		open(f.name, "w") do io
	    	write(io, read(f))
		end
    end
	close(r)
end

# ╔═╡ ada44a56-fc56-11ea-2ab7-fb649be7e066
shp_countries = Shapefile.shapes(Shapefile.Table("./ne_110m_admin_0_countries.shp"))

# ╔═╡ d911edb6-fc87-11ea-2258-d34d61c02245
poly = shp_countries[1]

# ╔═╡ d5db60c7-3b1c-4d45-bc5e-80056b94636a
pts = poly.points

# ╔═╡ 4e493c39-6ff8-4a8c-b5c2-95948ffff1b0
pts[1].x

# ╔═╡ f103787e-6880-407d-b079-3c78563f220a
gr()

# ╔═╡ 39310b7f-7f16-4eda-ac49-fc0bf965b24b
@bind which Slider(1:length(shp_countries))

# ╔═╡ b3e1ebf8-fc56-11ea-05b8-ed0b9e50503d
plot(shp_countries[which], alpha=0.2)

# ╔═╡ f8e754ee-fc73-11ea-0c7f-cdc760ab3e94
md"Now we would like to combine the geographical and temporal (time) aspects. One way to do so is to animate time:"

# ╔═╡ 39982810-fc76-11ea-01c3-3987cfc2fd3c
daily = max.(1, diff(Array(data[:, 5:end]), dims=2));

# ╔═╡ 0f329ece-fc74-11ea-1e02-bdbddf551ef3
@bind day2 Slider(1:size(daily, 2), show_value=true)

# @bind day Clock(0.5)

# ╔═╡ b406eec8-fc77-11ea-1a98-d36d6d3e2393
log10(maximum(daily[:, day]))

# ╔═╡ 1f30a1ac-fc74-11ea-2abf-abf437006bab
dates[day2]

# ╔═╡ 24934438-fc74-11ea-12e4-7f7e50f54029
world_plot = begin 
	plot(shp_countries, alpha=0.2)
	scatter!(data.longitude, data.latitude, leg=false, ms=2*log10.(daily[:, day]), alpha=0.7)
	xlabel!("longitude")
	ylabel!("latitude")
	title!("daily cases per country")
end


# ╔═╡ f7a37706-fcdf-11ea-048a-236b8ed0f1f3
world_plot

# ╔═╡ 251c06e4-fc77-11ea-1a0f-73139ba11e83
md"However, we should always be wary about visualisations such as these. Perhaps we should be plotting cases per capita instead of absolute numbers of cases. Or should we divide by the area of the country? Some countries, such as China and Canada, are divided into states or regions in the original data set -- but others, such as the US, are not. You should always check exactly what is being plotted! 

Unfortunately, published visualisations often hide some of  this information. This emphasises the need to be able to get our hands on the data, create our own visualisations and draw our own conclusions."

# ╔═╡ ad3eeea4-6596-4974-9ccf-1ce40d9d33ac


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
LsqFit = "2fda8390-95c7-5789-9bda-21331edee243"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Shapefile = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
ZipFile = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"

[compat]
CSV = "~0.10.7"
DataFrames = "~1.4.2"
LsqFit = "~0.13.0"
Plots = "~1.36.0"
PlutoUI = "~0.7.48"
Shapefile = "~0.8.0"
ZipFile = "~0.10.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "77d17912b8a779194f4d73042031224229f1f71c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "c46fb7dd1d8ca1d213ba25848a5ec4e47a1a1b08"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.26"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "c5fd7cd27ac4aed0acf4b73948f0110ff2a854b2"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.7"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBFTables]]
deps = ["Printf", "Tables", "WeakRefStrings"]
git-tree-sha1 = "f5b78d021b90307fb7170c4b013f350e6abe8fed"
uuid = "75c7ada1-017a-5fb6-b8c7-2125ff2d6c93"
version = "1.0.0"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5b93f1b47eec9b7194814e40542752418546679f"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "9a95659c283c9018ea99e017aa9e13b7e89fadd2"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "bee795cdeabc7601776abbd6b9aac2ca62429966"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.77"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

[[deps.FiniteDiff]]
deps = ["ArrayInterfaceCore", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "bb61d9e5085784fe453f70c97b23964c5bf36942"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.16.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "00a9d4abadc05b9476e937a5557fcce476b9e547"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.69.5"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "434166198434a5c2fcc0a1a59d22c3b0ad460889"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.1"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeoInterfaceRecipes]]
deps = ["GeoInterface", "RecipesBase"]
git-tree-sha1 = "29e1ec25cfb6762f503a19495aec347acf867a9e"
uuid = "0329782f-3d07-4b52-b9f6-d3137cf03c7a"
version = "1.0.0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "8c7e6b82abd41364b8ffe40ffc63b33e590c8722"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "a62189e59d33e1615feb7a48c0bea7c11e4dc61d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.LsqFit]]
deps = ["Distributions", "ForwardDiff", "LinearAlgebra", "NLSolversBase", "OptimBase", "Random", "StatsBase"]
git-tree-sha1 = "00f475f85c50584b12268675072663dfed5594b2"
uuid = "2fda8390-95c7-5789-9bda-21331edee243"
version = "0.13.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "50310f934e55e5ca3912fb941dec199b49ca9b68"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.2"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "5628f092c6186a80484bfefdf89ff64efdaec552"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OptimBase]]
deps = ["NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "9cb1fee807b599b5f803809e85c81b582d2009d6"
uuid = "87e2bd06-a317-5318-96d9-3ecbac512eee"
version = "2.0.2"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "ec23efe47c86da2c00dc5496e59cb3d36bbfce6d"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "98ac42c9127667c2731072464fcfef9b819ce2fa"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "d12e612bba40d189cead6ff857ddb67bd2e6a387"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "a030182cccc5c461386c6f055c36ab8449ef1340"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.10"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Shapefile]]
deps = ["DBFTables", "Extents", "GeoFormatTypes", "GeoInterface", "GeoInterfaceRecipes", "RecipesBase", "Tables"]
git-tree-sha1 = "2f400236c85ba357dfdc2a56af80c939dc118f02"
uuid = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
version = "0.8.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "ef4f23ffde3ee95114b461dc667ea4e6906874b2"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─d3398953-afee-4989-932c-995c3ffc0c40
# ╟─efa281da-cef9-41bc-923e-625140ce5a07
# ╠═7617d970-fce4-11ea-08ba-c7eba3e17f62
# ╠═b0e7f1c6-fce3-11ea-10e5-9101d0f861a2
# ╠═f7a37706-fcdf-11ea-048a-236b8ed0f1f3
# ╟─e0493940-8aa7-4733-af72-cd6bc0e37d92
# ╠═64d9bcea-7c85-421d-8f1e-17ea8ee694da
# ╠═c460b0c3-6d3b-439b-8cc7-1c58d6547f51
# ╟─a7369222-fc20-11ea-314d-4d6b0f0f72eb
# ╠═db4c1f10-7c37-4513-887a-2467ce673458
# ╟─1620aa9d-7dcd-4686-b7e4-a72cebe315ed
# ╠═38344160-fc27-11ea-220e-95aa00e4b083
# ╠═656aa2f1-95d4-45a1-b129-4271ecc14ac2
# ╠═2039f5c4-fe54-4808-9414-be29214123ef
# ╠═5f107c98-3514-44e7-be14-14b3806333db
# ╟─ad43cea2-fc28-11ea-2bc3-a9d81e3766f4
# ╟─fab64d86-fc28-11ea-0ae1-3ba1b9a14759
# ╟─3519cf96-fc26-11ea-3386-d97c61ea1b85
# ╠═ecb8098a-ceda-4739-aa8b-0ed72feccf4a
# ╠═a054e048-4fea-487c-9d06-463723c7151c
# ╠═4e30a9de-6b42-4d8d-a910-8e2999f6f52f
# ╠═283c8030-3683-4f73-aae2-9f01afca4194
# ╠═afc82e07-95e6-48cf-97a4-c88ebd4847d4
# ╠═e9ad97b6-fdef-4f48-bd32-634cfd2ce0e6
# ╠═ea444f4b-1524-4794-ae0a-bf75aac36749
# ╠═795daf44-bce2-478e-a7eb-2ae4811e32f4
# ╠═e31c3de7-5afa-4e82-84a1-db6b1fb22e9f
# ╠═fcd29e73-a154-43de-8534-d36bd7537c29
# ╠═a021c58d-0959-4de4-820f-619a367a69a8
# ╠═136e7560-55c8-4619-9c95-1a47cf66a58d
# ╠═58ae2194-4e47-468d-9ee8-043537ceccab
# ╠═46750c6d-4709-4589-b54c-7f86872db408
# ╟─aaa7c012-fc1f-11ea-3c6c-89630affb1db
# ╟─b0eb3918-fc1f-11ea-238b-7f5d23e424bb
# ╠═68f76d3b-b398-459d-bf39-20bf300dcaa2
# ╠═4668e229-548a-4391-a72d-230241b52bf7
# ╠═b1ad1c7a-0baf-459a-93c9-62b268643a77
# ╠═1e93c85d-8c8c-449f-ae1d-01689ac1df74
# ╠═20e144f2-fcfb-11ea-010c-97e21eb0d231
# ╠═2ec98a16-fcfb-11ea-21ad-15f2f5e68248
# ╠═382cfc62-fcfb-11ea-26aa-2984d0449dcc
# ╟─34440afc-fc2e-11ea-0484-5b47af235bad
# ╠═79ba0433-2a31-475a-87c9-14103ebbff16
# ╠═c72e3142-75c4-4ece-8f08-cbadda6ad4d1
# ╠═5c1ec9ae-fc2e-11ea-397d-937c7ab1edb2
# ╠═a39589ee-20e3-4f22-bf81-167fd815f6f9
# ╠═b7e1b68a-e04c-44d5-9f8d-d18b9afa51ab
# ╟─9484ea9e-fc2e-11ea-137c-6da8212da5bd
# ╟─bcc95a8a-fc2e-11ea-2ccd-3bece42a08e6
# ╠═ada3ceb4-fc2e-11ea-2cbf-399430fa18b5
# ╟─1633abe8-fc2f-11ea-2c7e-21b3348a3569
# ╟─ed383524-e0c0-4da2-9a98-ca75aadd2c9e
# ╠═90810d7e-fcfb-11ea-396a-35543dcc1e06
# ╠═977e1a2c-fcfb-11ea-08e9-cd656a631778
# ╠═9ee79840-30ff-4c92-97f4-e178caceceaf
# ╠═b3f7035f-2653-4a1d-8efc-532ce1bf1e19
# ╠═99d5a138-fc30-11ea-2977-71732ca3aead
# ╟─450b4902-fc30-11ea-321d-29faf6188ff5
# ╠═4f423a75-43da-486f-ac2a-7220032dac9f
# ╟─a8b2db96-fc30-11ea-2eea-b938a3a430fb
# ╟─c400ce4e-fc30-11ea-13b1-b54cf8f5630e
# ╠═7b2496b0-fc35-11ea-0e78-473e5e8eac44
# ╟─8990f13a-fc35-11ea-338f-0955eeb23c3c
# ╟─a772eadc-fc35-11ea-3d38-4b121f88f1d7
# ╠═16a79308-fc36-11ea-16e5-e1087d7ebbda
# ╠═a41db8ea-f0e0-461f-a298-bdcea42a67f3
# ╠═50cc0714-c73a-4622-8b09-6c9e8662637a
# ╠═e540e990-06b0-4a25-aca8-5d35b5ebac50
# ╠═fb756077-791e-424c-844e-523b44fe3bdc
# ╠═f75e1992-fcfb-11ea-1123-b59bf888eac3
# ╟─67eebb7e-fc36-11ea-03ef-bd6966487bb5
# ╟─7b5db0f4-fc36-11ea-09a5-49def64f4c79
# ╠═f099424c-0e22-42fb-894c-d8c2a65715fb
# ╟─7e7d14a2-fc37-11ea-3f1a-870ca98c4b75
# ╟─75d2dc66-fc47-11ea-0e35-05f9cf38e901
# ╟─b3880f40-fc36-11ea-074a-edc51adeb6f0
# ╟─6de0800c-fc37-11ea-0d94-2b6f8f66964d
# ╟─bb6316b7-23fb-44a3-b64a-dfb71a7df011
# ╠═0c098923-b016-4c65-9a37-6b7b56b13a0c
# ╟─546a40eb-7897-485d-a1b5-c4dfae0a4861
# ╠═cbd9c1aa-fc37-11ea-29d9-e3361406796f
# ╠═9e23b0e2-ac13-4d19-a3f9-4a655a1e9f14
# ╠═25c79620-14f4-45a7-b120-05ec72cb77e9
# ╠═9c123e2c-6cb7-4bcd-9f0f-fe06c809754b
# ╠═9807da0c-4344-450d-a8c1-b5dd64c39974
# ╠═4d434bca-7fce-4c81-9532-b28b4763a82f
# ╠═31dc4e46-4839-4f01-b383-1a1189aeb0e6
# ╠═34af7dc4-8ec9-4268-afb8-7f5ec7cd8e12
# ╠═9de44d78-5de2-4817-910b-14bb3442719f
# ╠═7467913a-ee1c-4c39-81fa-e277598d1725
# ╟─ee27bd98-fc37-11ea-163c-1365e194fc2e
# ╟─f5c29f0d-937f-4731-8f87-0405ebc966f5
# ╠═36c37b4d-eb23-4deb-a593-e511eccd9204
# ╠═443f876c-658b-45d2-8953-5f5cbc1c0a14
# ╠═5f304eb2-f495-4b63-8d25-faa5a35af78a
# ╠═6c2b6f2a-5a3d-481d-8f78-58bdf450e3a8
# ╠═5716677a-14fe-468d-9594-292f8f102bf0
# ╠═b01c053c-7199-4290-8870-57e2a8c91d09
# ╠═4d9228c2-6ce8-47d9-8ac4-1d6251e1c6f1
# ╠═e07cafab-327f-4bed-a210-e8467747846f
# ╠═52b494fc-e3f8-4248-b808-1c9cd0ab9cde
# ╟─511eb51e-fc38-11ea-0492-19532da809de
# ╟─d228e232-fc39-11ea-1569-a31b817118c4
# ╠═dbaacbb6-fc3b-11ea-0a42-a9792e8a6c4c
# ╟─12900562-fc3a-11ea-25e1-f7c91a6940e5
# ╠═19bdf146-fc3c-11ea-3c60-bf7823c43a1d
# ╠═be868a52-fc3b-11ea-0b60-7fea05ffe8e9
# ╟─0b01120c-fc3d-11ea-1381-8bab939e6214
# ╟─252eff18-fc3d-11ea-0c18-7b130ada882e
# ╟─9626d74a-fc3d-11ea-2ab3-978dc46c0f1f
# ╠═4af67287-b97c-4c25-9a17-088eda346b6f
# ╠═ecd64c32-6baa-496d-bc1a-21fe4c561e5a
# ╠═4358c348-91aa-4c76-a443-0a9cefce0e83
# ╠═fd5848a9-4fa8-4b6b-8ad9-05173d422273
# ╠═ef953d4a-4375-497e-9829-0498c5083c00
# ╟─687409a2-fc43-11ea-03e0-d9a7a48165a8
# ╠═4f23c8fc-fc43-11ea-0e73-e5f89d14155c
# ╠═b0e0d7fc-c77e-495d-a800-3f53a1ab2e51
# ╠═c85b20fb-c2a0-43d3-ae8d-bbe897667dfe
# ╟─07282688-fc3e-11ea-2f9e-5b0581061e65
# ╠═91f99062-fc43-11ea-1b0e-afe8aa8a1c3d
# ╠═210cee94-fc3e-11ea-1a6e-7f88270354e1
# ╟─2f254a9e-fc3e-11ea-2c02-75ed59f41903
# ╟─84f5c776-fce0-11ea-2d52-39c51d4ab6b5
# ╟─539c951c-fc48-11ea-2293-457b7717ea4d
# ╠═b33e97f2-fce0-11ea-2b4d-ffd7ed7000f8
# ╠═d52fc8fe-fce0-11ea-0a04-b146ee2dbe80
# ╟─c50b5e42-fce1-11ea-1667-91c56ea80dcc
# ╟─3060bfa8-fce1-11ea-1047-db0dc06485a2
# ╟─62bdc04a-fce1-11ea-1724-bfc4bc4789d1
# ╠═6bc8cc20-fce1-11ea-2180-0fa69e86741f
# ╟─287f0fa8-fc44-11ea-2788-9f3ac4ee6d2b
# ╟─3edd2a22-fc4a-11ea-07e5-55ca6d7639e8
# ╠═c5ad4d40-fc57-11ea-23cb-e55487bc6f7a
# ╟─57a9bb06-fc4a-11ea-2665-7f97026981dc
# ╠═80138b30-fc4a-11ea-0e15-b54cf6b402df
# ╟─8709f208-fc4a-11ea-0203-e13eae5f0d93
# ╠═a29c8ad0-fc4a-11ea-14c7-71435769b73e
# ╠═4e4cca22-fc4c-11ea-12ae-2b51545799ec
# ╠═16981da0-fc4d-11ea-37a2-535aa014a298
# ╟─a9c39dbe-fc4d-11ea-2e86-4992896e2abb
# ╟─b93b88b0-fc4d-11ea-0c45-8f64983f8b5c
# ╠═7ec28cd0-fc87-11ea-2de5-1959ea5dc37c
# ╟─ada44a56-fc56-11ea-2ab7-fb649be7e066
# ╠═d911edb6-fc87-11ea-2258-d34d61c02245
# ╠═d5db60c7-3b1c-4d45-bc5e-80056b94636a
# ╠═4e493c39-6ff8-4a8c-b5c2-95948ffff1b0
# ╠═f103787e-6880-407d-b079-3c78563f220a
# ╠═b3e1ebf8-fc56-11ea-05b8-ed0b9e50503d
# ╠═39310b7f-7f16-4eda-ac49-fc0bf965b24b
# ╟─f8e754ee-fc73-11ea-0c7f-cdc760ab3e94
# ╠═39982810-fc76-11ea-01c3-3987cfc2fd3c
# ╠═0f329ece-fc74-11ea-1e02-bdbddf551ef3
# ╠═b406eec8-fc77-11ea-1a98-d36d6d3e2393
# ╠═1f30a1ac-fc74-11ea-2abf-abf437006bab
# ╠═24934438-fc74-11ea-12e4-7f7e50f54029
# ╟─251c06e4-fc77-11ea-1a0f-73139ba11e83
# ╠═ad3eeea4-6596-4974-9ccf-1ce40d9d33ac
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
