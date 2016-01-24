%% Genera el sonido de una nota
% [salida] = sintetizador_guitarra(f, n_nota, n_ruido_blanco, min_bpm, fs)
% Entradas:
%   f               frecuencia de la nota (en Hz)
%   n_nota          longitud de la nota expresada en muestras
%   n_ruido_blanco  longitud del vector de ruido blanco que se filtrar�
%   min_bpm         m�nimo de pulsaciones por minuto de la canci�n
%   fs              frecuencia de muestreo (en Hz)
% Salidas
%   salida          array que contiene las muestras de la nota
function [salida] = sintetizador_guitarra(f, n_nota, n_ruido_blanco, min_bpm, fs)
Ts = 1/fs; % Periodo de muestreo
w = 2*pi*f; % Pulsaci�n
P1 = fs/f; % Retardo de fase requerido por una frecuencia f

% Mejora #1 para el decaimiento
s = 82.407/(2*f); % Extensi�n adaptativa del decaimiento

% Efecto de la extensi�n del decaimiento en la afinaci�n
Pa = -1/(w*Ts) * atan(-s*sin(w*Ts)/((1 - s) + s*cos(w*Ts))); % Retardo de fase (Ecuaci�n 22 del art�culo de Jaffe-Smith)
N = floor(P1 - Pa); % Longitud del retardo del filtro z^-n (Ecuaci�n 15 del art�culo de Jaffe-Smith)

% Mejora para la afinaci�n
Pc = P1 - N - Pa; % Retardo requerido por el filtro paso todo (Ecuaci�n 15 del art�culo de Jaffe-Smith)
C = sin((w*Ts - w*Ts*Pc)/2)/sin((w*Ts + w*Ts*Pc)/2); % Coeficientes de la funci�n de transferencia del filtro paso todo (Ecuaci�n 16 del art�culo de Jaffe-Smith)

% Definimos la funci�n de transferencia del sistema completo y filtramos la entrada
B = [1, C]; % Numerador de la funci�n de transferencia
A = [1, C, zeros(1, N - 2), C*(s - 1), s - s*C - 1, -s]; % Denominador de la funci�n de transferencia
entrada = [rand(1, n_ruido_blanco) - 0.5, zeros(1, (120/min_bpm)*fs)]; % Ruido blanco a la entrada
nota = filter(B, A, entrada); % Filtramos la entrada por el sistema para obtener la nota

% Mejora #2 para el decaimiento: Decaimiento exponencial al final de la nota para evitar que finalice de forma abrupta y antinatural
n_decaimiento =  length(entrada) - n_nota; % Longitud que tendr� el decaimiento exponencial (en n�mero de muestras)
n = 1:n_decaimiento; % �ndice para la exponencial
dec = [ones(1, length(nota) - n_decaimiento), exp(-n * 10/n_decaimiento)]; % Array de unos salvo las �ltimas n_decaimiento posiciones, en las cuales est� la exponencial negativa

% Devolvemos la nota sintetizada
salida = dec.*nota; % Aplicamos el decaimiento exponencial a la nota
end

%% Trabajo final del laboratorio de TDS�
% S�ntesis de sonido de guitarra
% Autores: Luis Garc�a de Fernando, Santiago Pant�n, Nuria de los Reyes, �scar V�zquez, Hussein Wehbe