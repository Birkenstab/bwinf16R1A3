part of aufgabe3;


class SolutionFinder {
    Set<SituationHash> checkedSituations;
    var sender;

    void startIsolate( sender ) {
        this.sender = sender;
        var rPort = new ReceivePort();
        sender.send(rPort.sendPort);

        rPort.listen((msg){
            print("Worker got: $msg");
            if ( msg is Situation ) {
                sender.send( new SolutionFinderResult( findSolution( msg ) ) );
            }
        });
    }

    /// Findet die Lösung zum gegebenen Puzzle
    /// Gibt den Pfad zur Lösung zurück oder null, wenn es keine Lösung gibt
    List<Situation> findSolution( Situation startingSituation ) {
        checkedSituations = new Set(); // Erzeugung eines Sets, das alle Hashwerte der schon überprüften Sitationen enthält
        Queue<Situation> paths = new Queue.from( [ startingSituation ] );
        var count = 0;

        while ( paths.isNotEmpty ) {
            sender.send( new SolutionFinderStatus( paths.length, count, checkedSituations.length ) );

            Iterable<Situation> currentPaths = paths;
            paths = new Queue();
            for ( Situation currentSituation in currentPaths ) {

                // Nach links drehen:
                Situation situationLeft = new Situation.from( currentSituation ); // Neue Situation erstellen
                situationLeft.orientation = getOrientationLeft( situationLeft.orientation );

                if ( situationLeft.applyGravity( ) ) { // Gravitation anwenden
                    return getPath( situationLeft ); // Wenn Lösung gefunden, den Pfad zurückgeben
                }

                if ( ! isSituationAlreadyChecked( situationLeft ) ) { // Prüfen ob diese Situation schon mal vorgekommen ist
                    checkedSituations.add( situationLeft.hash() );
                    paths.addLast( situationLeft ); // Situation in Liste mit Pfaden, die zurzeit verfolgt werden, eintragen
                }

                // Nach rechts drehen:
                Situation situationRight = new Situation.from( currentSituation ); // Neue Situation erstellen
                situationRight.orientation = getOrientationRight( situationRight.orientation );

                if ( situationRight.applyGravity( ) ) { // Gravitation anwenden
                    return getPath( situationRight ); // Wenn Lösung gefunden, den Pfad zurückgeben
                }

                if ( ! isSituationAlreadyChecked( situationRight ) ) { // Prüfen ob diese Situation schon mal vorgekommen ist
                    checkedSituations.add( situationRight.hash() );
                    paths.addLast( situationRight ); // Situation in Liste mit Pfaden, die zurzeit verfolgt werden, eintragen
                }

            }
            count++;
        }
        return null;
    }

    /// Überprüfen ob diese Situation schon einmal vorgekommen ist, damit keine Endlosschleifen entstehen
    bool isSituationAlreadyChecked( Situation situation ) {
        SituationHash hash = situation.hash();
        return checkedSituations.contains( hash );
    }

    /// Gibt die Orientation zurück, die man bekommt wenn man das Puzzle nach links dreht
    Orientation getOrientationLeft( Orientation orientation ) {
        return Orientation.values[ ( orientation.index - 1 + 4 ) % 4 ];
    }

    /// Gibt die Orientation zurück, die man bekommt wenn man das Puzzle nach rechts dreht
    Orientation getOrientationRight( Orientation orientation ) {
        return Orientation.values[ ( orientation.index + 1 ) % 4 ];
    }

    /// Gibt den Pfad zurück den man zu dieser Situation benötigt
    List<Situation> getPath( Situation situation ) {
        List<Situation> situations = [];
        while ( situation != null ) {
            situations.add( situation );
            situation = situation.previous;
        }
        return new List.from( situations.reversed );
    }

}

class SolutionFinderStatus {
    int paths;
    int steps;
    int uniqueSituations;

    SolutionFinderStatus( this.paths, this.steps, this.uniqueSituations );
}

class SolutionFinderResult {
    List<Situation> path;

    SolutionFinderResult( this.path );
}