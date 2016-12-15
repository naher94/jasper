Jasper is a color tool to expand your color vocabulary and provide a new form of inspiration for all.

Building on colors inspiration tools like [Adobe's Color](http://color.adobe.com), [Design Seeds](https://www.design-seeds.com/blog/) and [LOLColors](http://www.lolcolors.com). I want to give users daily color inspiration from Pantone's [color of the day](https://www.pantone.com/colorstrology). I would like to build a Slack bot to help users think about color in a new light (the Pantone light) and expand the user's color vocabulary. Additionally I would like users to have the option to request images that use that color for further inspiration. I plan to build this by pulling the color of the day from Pantone's [Colorstrology]( https://www.pantone.com/colorstrology) and using the color to search Dribbble or other such sites to surfaces images for the user.

For this iteration, I decided to build with an SMS bot using Twilio, to keep complexity down. I do plan to port Jasper to Slack as the interactions for a team will be far more compelling than that of an individual.

Sadnote: Pantone does not store a public list of all their daily colors :(

In this Version (V1.0) Jasper can pull up today’s color of the day provide up to 4 images what use that color, pull up yesterday’s color with images and have a bit of fun with the responses. The color data is scraped from Pantone's [Colorstrology](https://www.pantone.com/colorstrology) site and stored a database which is made up of 2 tables as show below. After the color data is collected a secondary function runs that scrapes 4 images from Dribbble given the hex value of the color, which is then stored in the images table.
