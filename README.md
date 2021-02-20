# Ekonometria przestrzenna - Spatial econometrics

Repozytorium zawiera skrypty dotyczące analizy i modeli ekonometrii przestrzennej.<br><br>
Zmienna przedstawiona w modelach odnosi się do wskaźnika zgłoszeń patentowych w dziedzinie patentów nowych technologii na milion mieszkańców regionów Niemiec w 2011 roku.<br><br>

[Macierze wag przestrzennych - Spatial weights matrices](#Macierze-wag-przestrzennych---Spatial-weights-matrices)<br>
[Testowanie procesów przestrzennych - Testing for spatial effects](#Testowanie-procesów-przestrzennych---Testing-for-spatial-effects)<br>
[Single source spatial regression](#Single-source-spatial-regression)<br>
[SAR SEM SLX models](#SAR-SEM-SLX-models)<br>
[SARAR SDM SDEM models](#SARAR-SDM-SDEM-models)<br>
<br>

## Macierze wag przestrzennych - Spatial weights matrices
Macierz <b>W</b> jest macierzą kwadratową o wymiarze równym liczbie regionów. Jej i-ty wiersz interpretujemy jako wektor wag, które określają wpływ innych regionów na i-ty region.<br>
![Centroids of regions](https://github.com/NataeSz/Spatial-econometrics/tree/master/imgs/centroids.jpeg)
<br>

## Testowanie procesów przestrzennych - Testing for spatial effects
Badany model regresji liniowej opisuje wpływ liczby ludności, PKB per capita oraz współczynnika zatrudnienia osób w wieku 15-64 lat na liczbę zgłoszeń patentowych na milion mieszkańców regionu.<br>
'''Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) -2.752e+02  7.510e+01  -3.665 0.000861 ***
Population   4.816e-06  2.540e-06   1.896 0.066761 .  
GDP          1.628e-03  3.775e-04   4.313 0.000137 ***
emp          3.268e+00  1.020e+00   3.204 0.003003 ** 
Multiple R-squared:  0.5645
'''
Na poziomie istotności równym 0,1 wszystkie zmienne niezależne są istotne i dodatnio skorelowane ze zmienną objaśnianą.<br><br>
#### Test Globalny i Lokalny Morana
'''Moran I statistic standard deviate = -0.71645, p-value = 0.7631
alternative hypothesis: greater
'''
Na każdym typowym poziomie istotności brak podstaw do odrzucenia hipotezy zerowej mówiącej o braku autokorelacji przestrzennej.<br><br>
![Moran's plot](https://github.com/NataeSz/Spatial-econometrics/tree/master/imgs/Moran.jpg)<br>
#### Test Gearyego
'''Geary C statistic standard deviate = -0.96634, p-value = 0.8331
alternative hypothesis: Expectation greater than statistic
'''
Na każdym typowym poziomie istotności brak podstaw do odrzucenia hipotezy zerowej mówiącej o braku autokorelacji przestrzennej.<br><br>
#### Test liczby połączeń
'''Std. deviate for TRUE = -0.57745, p-value = 0.7182
'''
Na każdym typowym poziomie istotności brak podstaw do odrzucenia hipotezy zerowej mówiącej o braku autokorelacji przestrzennej.<br><br>
#### Analiza wrażliwości testu liczby połączeń
![Join count test](https://github.com/NataeSz/Spatial-econometrics/tree/master/imgs/test_liczby_polaczen.jpg)<br>
Dla pojedynczych wartości progu podziału reszt odrzucimy hipotezę zerową na rzecz alternatywnej mówiącej o występowaniu autokorelacji przestrzennej reszt.<br>









