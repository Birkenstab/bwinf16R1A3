part of aufgabe3;

class SituationParser {
    static Situation parse( String input ) {
        Situation situation = new Situation( );
        List<String> rows = input.split( "\n" );
        int height = int.parse( rows.removeAt( 0 ) ) - 2;
        situation.height = height;

        if ( height < 1 )
            throw new FormatException( "At least height 3 ist needed" );

        if ( rows.length < height + 2 )
            throw new FormatException( "Not enough lines given" );

        List<String> firstRow = rows.removeAt( 0 ).split( "" );
        situation.width = firstRow.length - 2;
        for ( int i = 0; i < firstRow.length; i++ ) {
            if ( firstRow[i] == " " ) {
                situation.exitY = - 1;
                situation.exitX = i + 1;
            } else if ( firstRow[i] != "#" ) {
                throw new FormatException( "Expected '#' or ' ' in line 2" );
            }
        }
        rows.length = height + 1;

        List<List> blocks = [];
        for ( int i = 0; i < rows.length - 1; i++ ) {
            List<String> columns = new List.from( rows[i].split( "" ) );
            if ( columns.removeAt( 0 ) == " " ) {
                situation.exitX = - 1;
                situation.exitY = i;
            }
            for ( int j = 0; j < columns.length - 1; j++ ) {
                if ( columns[j] != " " ) {
                    int id = int.parse( columns[j] );
                    if ( blocks.length <= id || blocks[ id ] == null ) {
                        if ( blocks.length <= id )
                            blocks.length = id + 1;
                        blocks[ id ] = [];
                    }
                    blocks[ id ].add( {
                        "y": i,
                        "x": j
                    } );
                }
            }
            if ( columns.last == " " ) {
                situation.exitX = columns.length - 1;
                situation.exitY = i;
            }
        }


        List<String> lastRow = rows.removeLast( ).split( "" );
        for ( int i = 0; i < lastRow.length; i++ ) {
            if ( lastRow[i] == " " ) {
                situation.exitY = height;
                situation.exitX = i - 1;
            } else if ( lastRow[i] != "#" ) {
                throw new FormatException( "Expected '#' or ' ' in last line" );
            }
        }

        for ( int i = 0; i < blocks.length; i++ ) {
            var locations = blocks[i];
            int minX = 9999; // TODO schöner lösen
            int minY = 9999;
            int maxX = 0;
            int maxY = 0;
            for ( var location in locations ) {
                if ( minX > location["x"] )
                    minX = location["x"];
                if ( maxX < location["x"] )
                    maxX = location["x"];
                if ( minY > location["y"] )
                    minY = location["y"];
                if ( maxY < location["y"] )
                    maxY = location["y"];
            }
            situation.steine.add( new Stein( i, minX, minY, maxX - minX + 1, maxY - minY + 1 ) );
        }

        if ( situation.height > 16 || situation.width > 16 ) {
            throw new FormatException( "Puzzle darf höchstens 16x16 Felder groß sein");
        }
        if ( situation.steine.length > 12 )
            throw new FormatException( "Puzzle darf höchstens 12 Steine enthalten");

        return situation;
    }
}