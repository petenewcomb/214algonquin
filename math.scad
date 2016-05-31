function sum( v, i = 0) = i < len( v) ? v[ i] + sum( v, i + 1) : 0;

function vector_sum( v, i = 0) = i < len( v) - 1 ? let( w = vector_sum( v, i + 1)) [ for ( j = [ 0: len( w) - 1]) v[ i][ j] + w[ j]] : v[ i];
function vector_difference( a, b) = [ for ( i = [ 0: len( a) - 1]) a[ i] - b[ i]];
function vector_length( v) = sqrt( sum( [ for ( i = v) i * i]));
function vector_scale( v, x) = [ for ( i = v) i * x];

function normalize_angle( a) =
        a < -180
        ? normalize_angle( a + 360)
        : ( a > 180
            ? normalize_angle( a - 360)
            : a);

function polar_to_vector( a, m) =
        [ cos( a) * m, sin( a) * m];

function vector_to_angle( v) = atan2( v[ 1], v[ 0]);
function vector_to_polar( v) = [ vector_to_angle( v), vector_length( v)];
