initialize; config;

%% R-E region calculation
nAngles = size(channelRelativeAngle, 2);
nWeights = size(weight, 2);

dpcRate = cell(nAngles, nWeights);
mulpRate = cell(nAngles, nWeights);
nomaRate = cell(nAngles, nWeights);
slrsRate = cell(nAngles, nWeights);
rsRate = cell(nAngles, nWeights);

for iAngle = 1 : nAngles
    % update BC channel of user 2
    bcChannel(:, :, 2) = kron(channelRelativeStrength, exp(1j * channelRelativeAngle(iAngle) * (0 : 3)));
    for iWeight = 1 : nWeights
        [dpcRate{iAngle, iWeight}] = dpc_rate(weight(:, iWeight), bcChannel, snr, tolerance);
        [mulpRate{iAngle, iWeight}] = mulp_rate(weight(:, iWeight), bcChannel, snr, tolerance);
        [nomaRate{iAngle, iWeight}] = noma_rate(weight(:, iWeight), bcChannel, snr, tolerance);
        [slrsRate{iAngle, iWeight}] = slrs_rate(weight(:, iWeight), bcChannel, snr, tolerance, rsRatio);
        [rsRate{iAngle, iWeight}] = rs_rate(weight(:, iWeight), bcChannel, snr, tolerance, rsRatio);
    end
end

%% R-E region comparison
figure('Name', sprintf('Achievable rate region comparison for %d-user %d-tx deployment, with \gamma = %d and SNR = %d dB', [user, rx, channelRelativeStrength, snr]));
legendString = cell(nAngles, 1);
for iAngle = 1 : nAngles
    subplot(2, 2, iAngle);
    % DPC
    dpcPlot = plot(dpcRate{iAngle, :});
    legendString{1} = sprintf('DPC');

    % MU-LP
    mulpPlot = plot(mulpRate{iAngle, :});
    legendString{2} = sprintf('MU-LP');

    % NOMA
    nomaIdx = convhull(nomaRate{iAngle, :});
    nomaPlot = plot(sortrow(nomaRate{iAngle, nomaIdx}));
    legendString{3} = sprintf('NOMA');

    % Single-layer RS
    slrsPlot = plot(slrsRate{iAngle, :});
    legendString{4} = sprintf('SLRS');

    % RS
    rsIdx = convhull(rsRate{iAngle, :});
    rsPlot = plot(sortrow(rsRate{iAngle, rsIdx}));
    legendString{5} = sprintf('RS');
end
