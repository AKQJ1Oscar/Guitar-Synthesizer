%% Genera el sonido de una nota
% [salida] = sintetizador_guitarra(f, n_nota, n_ruido_blanco, min_bpm, fs)
% Entradas:
%   f               frecuencia de la nota (en Hz)
%   n_nota          longitud de la nota expresada en muestras
%   n_ruido_blanco  longitud del vector de ruido blanco que se filtrará
%   min_bpm         mínimo de pulsaciones por minuto de la canción
%   fs              frecuencia de muestreo (en Hz)
% Salidas
%   salida          array que contiene las muestras de la nota
function [salida] = sintetizador_guitarra(f, n_nota, n_ruido_blanco, min_bpm, fs)
Ts = 1/fs; % Periodo de muestreo
w = 2*pi*f; % Pulsación
P1 = fs/f; % Retardo de fase requerido por una frecuencia f

% Mejora #1 para el decaimiento
s = 82.407/(2*f); % Extensión adaptativa del decaimiento

% Efecto de la extensión del decaimiento en la afinación
Pa = -1/(w*Ts) * atan(-s*sin(w*Ts)/((1 - s) + s*cos(w*Ts))); % Retardo de fase (Ecuación 22 del artículo de Jaffe-Smith)
N = floor(P1 - Pa); % Longitud del retardo del filtro z^-n (Ecuación 15 del artículo de Jaffe-Smith)

% Mejora para la afinación
Pc = P1 - N - Pa; % Retardo requerido por el filtro paso todo (Ecuación 15 del artículo de Jaffe-Smith)
C = sin((w*Ts - w*Ts*Pc)/2)/sin((w*Ts + w*Ts*Pc)/2); % Coeficientes de la función de transferencia del filtro paso todo (Ecuación 16 del artículo de Jaffe-Smith)

% Definimos la función de transferencia del sistema completo y filtramos la entrada
B = [1, C]; % Numerador de la función de transferencia
A = [1, C, zeros(1, N - 2), C*(s - 1), s - s*C - 1, -s]; % Denominador de la función de transferencia
entrada = [rand(1, n_ruido_blanco) - 0.5, zeros(1, (120/min_bpm)*fs)]; % Ruido blanco a la entrada
nota = filter(B, A, entrada); % Filtramos la entrada por el sistema para obtener la nota

% Mejora #2 para el decaimiento: Decaimiento exponencial al final de la nota para evitar que finalice de forma abrupta y antinatural
n_decaimiento =  length(entrada) - n_nota; % Longitud que tendrá el decaimiento exponencial (en número de muestras)
n = 1:n_decaimiento; % Índice para la exponencial
dec = [ones(1, length(nota) - n_decaimiento), exp(-n * 10/n_decaimiento)]; % Array de unos salvo las últimas n_decaimiento posiciones, en las cuales está la exponencial negativa

% Devolvemos la nota sintetizada
salida = dec.*nota; % Aplicamos el decaimiento exponencial a la nota
end

%% Trabajo final del laboratorio de TDSÑ
% Síntesis de sonido de guitarra
% Autores: Luis García de Fernando, Santiago Pantín, Nuria de los Reyes, Óscar Vázquez, Hussein Wehbe