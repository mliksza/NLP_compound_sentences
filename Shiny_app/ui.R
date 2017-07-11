library(shiny)

fluidPage(
  
  textAreaInput(inputId = "sentences", label = "Wprowadź zdania, które mają być rozłożone na zdania proste: ", 
            value = "Witam, obecnie jesteśmy z chlopakiem w Indonezji. Okolo godziny 11 polskiego czasu 
            (17 indonezyjskiego) próbowalismy wypłacić pieniadze z dwoch roznych kart. Chlopak ma Vise w €,
            ja MasterCarcd w $. Zadnemu z nas nie udało sie wypłacić pieniedzy z dwoch roznych bankomatow. 
            Pojawiają sie komunikaty by skontaktyowac sie z bankiem, bo transakcja nie moze zostać zrealizowana. 
            Dodam ze w tamtym tygodniu wyplacałam pieniadze bez problemu. Chlopak raz miał problem ale po kilku 
            godzinak w tym samym bankomavie transakcja przeszła. Od prawie trzech miesiecy jesteśmy w podrozy. 
            Wczesniej, w Tajlandii i Kambodzy wszelkie wyplaty szły bez zadnego problemu. Co sie u was dzieje??? 
            Wyjazd byl zgloszony na infolinie. Pani ponoc zanotowała kraje w jakich będziemy i czas podrozy.", 
            width = NULL, placeholder = NULL),
  submitButton("Podziel na zdania pojedyncze."),
  htmlOutput("splitted_sentences")
  
  )