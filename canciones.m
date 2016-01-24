%% Canciones
% Frecuencias de las notas en la sexta cuerda de la guitarra (en Hz)
f_notas = [82.407, 87.307, 92.499, 97.999, 103.826, 110, 116.541, 123.471, 130.813, 138.592, 146.833, 155.564];
do = f_notas(9);
do_s = f_notas(10);
re = f_notas(11);
re_s = f_notas(12);
mi = f_notas(1);
fa = f_notas(2);
fa_s = f_notas(3);
sol = f_notas(4);
la_b = f_notas(5);
la = f_notas(6);
si_b = f_notas(7);
si = f_notas(8);

% Figuras musicales
negra = 1;
blanca = negra*2;
redonda = negra*4;
corchea = negra/2;
semicorchea = negra/4;
fusa = negra/8;
semifusa = negra/16;

% Selección de la canción
prompt = 'Seleccione la canción\n    Escriba un 1 para "Cumpleaños Feliz"\n    Escriba un 2 para "Para Elisa"\n    Escriba un 3 para "El Padrino"\n';
seleccion = input(prompt);
while (seleccion ~= 1) && (seleccion ~= 2) && (seleccion ~= 3)
    prompt = '    Escriba un 1 para "Cumpleaños Feliz"\n    Escriba un 2 para "Para Elisa"\n    Escriba un 3 para "El Padrino"\n';
    seleccion = input(prompt);
end
if seleccion == 1 % Canción 1: Cumpleaños Feliz
    nombre = 'Cumpleaños Feliz';
    octavas = 2;
    notas = [do do re do fa*2 mi*2 do do re do sol*2 fa*2 do do do*2 la*2 fa*2 mi*2 re si_b*2 si_b*2 la*2 fa*2 sol*2 fa*2];
    figuras = [corchea*1.5 semicorchea negra negra negra blanca corchea*1.5 semicorchea negra negra negra blanca corchea*1.5 semicorchea negra negra negra negra blanca corchea*1.5 semicorchea negra negra negra blanca];
elseif seleccion == 2 % Canción 2: Para Elisa
    nombre = 'Para Elisa';
    octavas = 3;
    notas = [mi*4 re_s*2 mi*4 re_s*2 mi*4 si*2 re*2 do*2 la*2 do mi*2 la*2 si*2 mi*2 la_b*2 si*2 do*2 mi*2 mi*4 re_s*2 mi*4 re_s*2 mi*4 si*2 re*2 do*2 la*2 do mi*2 la*2 si*2 mi*2 do*2 si*2 la*2];
    figuras = [corchea corchea corchea corchea corchea corchea corchea corchea negra*1.5 corchea corchea corchea negra*1.5 corchea corchea corchea negra*1.5 corchea corchea corchea corchea corchea corchea corchea corchea corchea negra*1.5 corchea corchea corchea negra*1.5 corchea corchea corchea blanca];
elseif seleccion == 3 % Canción 3: El Padrino
    nombre = 'El Padrino';
    octavas = 1;
    notas = [sol do re_s re do re_s do re do la_b si_b sol];
    figuras = [corchea corchea corchea corchea corchea corchea corchea corchea corchea corchea corchea blanca];
end

% Parámetros de la canción
fs = 44100; % Frecuencia de muestreo (en Hz)
min_bpm = 20; % Mínimo de pulsaciones por minuto de la canción
fprintf('Introduzca el número de pulsaciones por minuto (mínimo %2.0f): ', min_bpm);
prompt = '';
bpm = input(prompt); % pulsaciones por minuto
while bpm < min_bpm
        fprintf('El mínimo de pulsaciones por minuto es %2.0f\nIntroduzca el número de pulsaciones por minuto: ',min_bpm);
        prompt = '';
        bpm = input(prompt);
end
prompt = 'Indique qué octava quiere que sea la más grave: ';
octava = input(prompt);
octavas_max = 5 - octavas;
while (octava < 1) || (octava > octavas_max)
    fprintf('Una guitarra de 6 cuerdas tiene 4 octavas\nDebe introducir un número entre 1 y %1.0f ya que la canción abarca %1.0f octavas: ', octavas_max, octavas);
    prompt = '';
    octava = input(prompt);
end

% Generación de la canción
t_pulsacion = 1e3/(bpm/60); % Tiempo de una negra (en ms)
t_cancion = sum(t_pulsacion * figuras); % Tiempo de la canción (en ms)
t_inicio = 0; % Tiempo en el que se inicia la primera nota (en ms)
for i = 1:length(figuras)-1
    t_inicio = [t_inicio, t_pulsacion*figuras(i) + t_inicio(i)]; % Tiempo en el que se inicia cada nota (en ms)
end
ini_muestras = floor((t_inicio/1e3) * fs); % Convierte los inicios en ms a inicios en número de muestras
t_final = [t_inicio(1, 2:length(t_inicio)), t_cancion]; % Tiempo en el que finaliza cada nota (en ms)
fin_muestras = floor((t_final/1e3) * fs); % Convierte los finales en ms a inicios en número de muestras
n_ruido_blanco = 1000; % Longitud del vector de ruido blanco que se filtrará en la función sintetizador_guitarra
n_cancion = max(ini_muestras) + n_ruido_blanco + (120/min_bpm)*fs; % Longitud de la canción (en número de muestras)
cancion = zeros(1, n_cancion); % Crea el array que contendrá la canción
for i = 1:length(notas) % Para cada nota
	n_nota = fin_muestras(i) - ini_muestras(i); % Longitud de la nota
	nota = sintetizador_guitarra((2^(octava - 1))*notas(i), n_nota, n_ruido_blanco, min_bpm, fs); % Se sintetiza la nota
	nota = [zeros(1, ini_muestras(i)-1), nota]; % Zero padding para el inicio
	nota = [nota, zeros(1, length(cancion)-length(nota))]; % Zero padding para el final
	cancion = nota + cancion; % Añade la nota a la canción
end
soundsc(cancion, fs);

% Información que se imprime por pantalla
fprintf('Sonando: %s\n', nombre);
if (bpm >= 40) && (bpm <= 43)
    fprintf('Tempo: Grave (%2.0f bpm)\n', bpm);
elseif (bpm >= 44) && (bpm <= 47)
    fprintf('Tempo: Largo (%2.0f bpm)\n', bpm);
elseif (bpm >= 48) && (bpm <= 51)
    fprintf('Tempo: Larghetto (%2.0f bpm)\n', bpm);
elseif (bpm >= 52) && (bpm <= 54)
    fprintf('Tempo: Adagio (%2.0f bpm)\n', bpm);
elseif (bpm >= 55) && (bpm <= 65)
    fprintf('Tempo: Andante (%2.0f bpm)\n', bpm);
elseif (bpm >= 66) && (bpm <= 69)
    fprintf('Tempo: Andantino (%2.0f bpm)\n', bpm);
elseif (bpm >= 70) && (bpm <= 95)
    fprintf('Tempo: Moderato (%2.0f bpm)\n', bpm);
elseif (bpm >= 96) && (bpm <= 112)
    fprintf('Tempo: Allegretto (%2.0f bpm)\n', bpm);
elseif (bpm >= 113) && (bpm <= 120)
    fprintf('Tempo: Allegro (%3.0f bpm)\n', bpm);
elseif (bpm >= 121) && (bpm <= 140)
    fprintf('Tempo: Vivace (%3.0f bpm)\n', bpm);
elseif (bpm >= 141) && (bpm <= 175)
    fprintf('Tempo: Presto (%3.0f bpm)\n', bpm);
elseif (bpm >= 176) && (bpm <= 208)
    fprintf('Tempo: Prestissimo (%3.0f bpm)\n', bpm);
else
    fprintf('Tempo: %3.0f bpm\n', bpm);
end
fprintf('Octava más grave: %1.0fª octava\n\n', octava);

%% Trabajo final del laboratorio de TDSÑ
% Síntesis de sonido de guitarra
% Autores: Luis García de Fernando, Santiago Pantín, Nuria de los Reyes, Óscar Vázquez, Hussein Wehbe