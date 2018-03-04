part of aufgabe3;

class Stein {
    int x;
    int y;
    int width;
    int height;
    int id;

    Stein( this.id, this.x, this.y, this.width, this.height );

    Stein.from( Stein stein ) {
        x = stein.x;
        y = stein.y;
        width = stein.width;
        height = stein.height;
        id = stein.id;
    }

    int get x2 => x + width - 1;

    void set x2( x2 ) {
        x = x2 - width + 1;
    }

    int get y2 => y + height - 1;

    void set y2( y2 ) {
        y = y2 - height + 1;
    }
}