# Ekonometria przestrzenna - Spatial econometrics

Repozytorium zawiera skrypty dotyczące analizy i modeli ekonometrii przestrzennej.<br><br>
Zmienna przedstawiona w modelach odnosi się do wskaźnika zgłoszeń patentowych w dziedzinie patentów nowych technologii na milion mieszkańców regionów Niemiec w 2011 roku.<br><br>

[Macierze wag przestrzennych - Spatial weights matrices](#Macierze-wag-przestrzennych)<br>
[Testowanie procesów przestrzennych - Testing for spatial effects](#Testowanie-procesów-przestrzennych)<br>
[Proste modele regresji - Single source spatial regression](#Proste-modele-regresji)<br>
[SAR SEM SLX models](#SAR-SEM-SLX-models)<br>
[SARAR SDM SDEM models](#SARAR-SDM-SDEM-models)<br>
<br>

## Macierze wag przestrzennych
Macierz <b>W</b> jest macierzą kwadratową o wymiarze równym liczbie regionów. Jej i-ty wiersz interpretujemy jako wektor wag, które określają wpływ innych regionów na i-ty region.<br>
![Centroids of regions](https://github.com/NataeSz/Spatial-econometrics/blob/master/imgs/centroids.jpeg?raw=true) ![Centroids](https://github.com/NataeSz/Spatial-econometrics/blob/master/imgs/centroids1.jpeg?raw=true)
<br>

## Testowanie procesów przestrzennych
Badany model regresji liniowej opisuje wpływ liczby ludności, PKB per capita oraz współczynnika zatrudnienia osób w wieku 15-64 lat na liczbę zgłoszeń patentowych na milion mieszkańców regionu.<br>
```
Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) -2.752e+02  7.510e+01  -3.665 0.000861 ***
Population   4.816e-06  2.540e-06   1.896 0.066761 .  
GDP          1.628e-03  3.775e-04   4.313 0.000137 ***
emp          3.268e+00  1.020e+00   3.204 0.003003 ** 
Multiple R-squared:  0.5645
```
Na poziomie istotności równym 0,1 wszystkie zmienne niezależne są istotne i dodatnio skorelowane ze zmienną objaśnianą.<br><br>
#### Test Globalny i Lokalny Morana
```
Moran I statistic standard deviate = -0.71645, p-value = 0.7631
alternative hypothesis: greater
```
Na każdym typowym poziomie istotności brak podstaw do odrzucenia hipotezy zerowej mówiącej o braku autokorelacji przestrzennej.<br><br>
![Moran's plot](https://github.com/NataeSz/Spatial-econometrics/blob/master/imgs/Moran.jpg?raw=true)<br>
#### Test Gearyego
```
Geary C statistic standard deviate = -0.96634, p-value = 0.8331
alternative hypothesis: Expectation greater than statistic
```
Na każdym typowym poziomie istotności brak podstaw do odrzucenia hipotezy zerowej mówiącej o braku autokorelacji przestrzennej.<br><br>

#### Test liczby połączeń
```
Std. deviate for TRUE = -0.57745, p-value = 0.7182
```
Na każdym typowym poziomie istotności brak podstaw do odrzucenia hipotezy zerowej mówiącej o braku autokorelacji przestrzennej.<br><br>
#### Analiza wrażliwości testu liczby połączeń
![Join count test](https://github.com/NataeSz/Spatial-econometrics/blob/master/imgs/test_liczby_polaczen.jpg?raw=true)<br>
Dla pojedynczych wartości progu podziału reszt odrzucimy hipotezę zerową na rzecz alternatywnej mówiącej o występowaniu autokorelacji przestrzennej reszt.<br>


## Proste modele regresji
## SAR SEM SLX models
#### Model SAR
```
SAR
Type: lag
Coefficients: (asymptotic standard errors)
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) -3.4382e+02  7.4583e+01  -4.6099 4.03e-06 
Population   2.3962e-06  2.2591e-06   1.0607 0.288832   
GDP          1.3962e-03  3.3257e-04   4.1982 2.69e-05 
emp          4.2521e+00  1.0347e+00   4.1095 3.96e-05  
Freq         2.3729e-01  7.5812e+00   3.1300 0.001748  

Rho: -0.053554, LR test value: 0.10134, p-value: 0.75023
Asymptotic standard error: 0.16653
    z-value: -0.32159, p-value: 0.74776
Wald statistic: 0.10342, p-value: 0.74776
```

Na poziomie istotności równym 0.1 brak podstaw do odrzucenia H0 mówiącej o tym, że ρ wynosi zero na rzecz hipotezy alternatywnej (ρ różne od zera). <br>
Na podstawie modelu SAR nie mamy do czynienia z modelem przestrzennym SAR, ujemne ρ jest akceptowalne.<br>

#### Model SEM
```
SEM
Type: error
Coefficients: (asymptotic standard errors)
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) -3.6218e+02  4.9655e+01  -7.2939 3.01e-13 
Population   2.0312e-06  2.1701e-06   0.9360 0.349273   
GDP          1.4705e-03  2.8494e-04   5.1608 2.45e-07 
emp          4.2521e+00  6.9430e+00   6.4372 1.22e-10  
Freq         2.3729e-01  7.3016e+00   3.2170 0.001295

Lambda: -0.52837, LR test value: 2.9172, p-value: 0.097639
Asymptotic standard error: 0.24036
    z-value: -2.1983, p-value: 0.02793
Wald statistic: 4.8324, p-value: 0.02793
```

Na poziomie istotności równym 0.1 odrzucamy H0 mówiącej o tym, że λ wynosi zero na rzecz hipotezy alternatywnej (λ różna od zera). Mamy do czynienia z modelem przestrzennym SEM. λ < 0, więc autoregresja przestrzenna jest nieistotna.<br>

#### Model SLX
Wektor parametrów przy opóźnieniach przestrzennych <b>θ</b> różni się znakiem dla zmiennej opisującej wielkość populacji w porównaniu do wektora parametrów <b>β</b>, lecz jest to zmienna statystycznie nieistotna dla każdego poziomu istotności. Opóźnienie przestrzenne GDP wzmacnia oddziaływanie tej zmiennej na wskaźnik zgłoszeń patentowych w regionie.<br><br>



### Sources
* [http://download.geofabrik.de/europe/germany/](http://download.geofabrik.de/europe/germany/)
* [https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00041](https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00041)
* [https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00096](https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00096)
* [https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00005](https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00005)
* [https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00007](https://ec.europa.eu/eurostat/web/products-datasets/-/tgs00007)
* [http://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts#nuts13](http://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts#nuts13)
<br><br>
*R Core Team (2020).* <br>
*R: A language and environment for statistical computing.* <br>
*R Foundation for Statistical Computing, Vienna, Austria.* <br>
*URL https://www.R-project.org/.* <br>
<br>
