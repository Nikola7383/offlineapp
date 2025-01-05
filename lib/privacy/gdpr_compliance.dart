class GDPRCompliance {
  static bool validatePrivacy() {
    return [
      _checkDataCollection(), // Ne skupljamo podatke
      _checkDataStorage(), // Lokalno šifrovano čuvanje
      _checkDataProcessing(), // Nema obrade podataka
      _checkDataAccess(), // Samo korisnik ima pristup
      _checkDataDeletion(), // Potpuno brisanje na zahtev
    ].every((check) => check == true);
  }
}
