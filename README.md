# BatAnalyzer
A MacOS Application that allows people to contribute to citizen-science by downloading and and analyzing bat calls for the BatIdentification Project

<h2> Features </h2>

<ul>
<li> Uses the authorization code grant flow to get permisson from BatIdentification to act on a users behalf </li>
<li> Retrieves information about a bat call from the BatIdentification API</li>
<li> Downloads that bat call </li>
<li> Uses SoX to generate a spectrogram and time expansion audio of that call</li>
<li> Uploads that call to BatIdentification</li>
</ul>

<h2> Setting up </h2>

Clone this repository to somewhere on your computer 

```bash
git clone https://github.com/richardbeattie/BatAnalyzer.git
```

Install the neccessary dependencies with Carthage

```bash
carthage build
```

<h2> Contributing </h2>

If you want to contribute or feel like there is a feature that should be implemented you can submit an issue 

Then you can clone the repository, make your changes, and submit a pull request

<h2> License </h2>

This program is licensed under the MIT license
