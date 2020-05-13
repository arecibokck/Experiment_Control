

function phase = phaseFunctionHandle(timeGrid)


    timeGrid = timeGrid * 1e6;

    phaseEndPoints = [0, 2*pi];
    initialHoldTime = 1;
    transportTime = 4;
    finalHoldTime = 1;
    phaseModulation = [-8.9674e-04 0.6300 -0.0071 0.0115 0.0198 -0.1445 0.0090 0.1030 -0.0065 0.0665];

    totalTime = initialHoldTime + transportTime + finalHoldTime;
    
    % Get indices of initial, final and transport times:
    isInitialHoldTime = (timeGrid < initialHoldTime);
    isFinalHoldTime   = (timeGrid > totalTime - finalHoldTime);
    isTransportTime   = ~ (isInitialHoldTime | isFinalHoldTime);
    
    
    phase = zeros(size(timeGrid));

    % Set linear phase ramp:
    phase(isInitialHoldTime) = phaseEndPoints(1);
    phase(isTransportTime) = phaseEndPoints(1) ...
        + (timeGrid(isTransportTime) - initialHoldTime) ...
        / transportTime ...
        * (phaseEndPoints(2) - phaseEndPoints(1));
    phase(isFinalHoldTime) = phaseEndPoints(2);
    
    % Set harmonic modulation for the phase ramp:
    for iMod = 1 : length(phaseModulation)
        phase(isTransportTime) = phase(isTransportTime) ...
            + phaseModulation(iMod) ...
            * sin(pi * iMod / transportTime ...
            * (timeGrid(isTransportTime) - initialHoldTime));
    end
    
end