% prepDenoiseGroup.m
%
%      usage: prepDenoiseGroup(v, varargin)
%         by: eli & laura
%       date: 01/17/15
%    purpose: create an additional group in which each run is concatenated
%    to get warping

function v = prepDenoiseGroup(v)

nScans = viewGet(v, 'nscans');

for iScan = 1:nScans
    [v params] = concatTSeries(v, [], 'justGetParams=1', 'defaultParams=1', sprintf('scanList=%i',iScan));
    params.percentSignal = 0;
    params.filterType = 'none';
    params.warpInterpMethod = 'linear';
    params.warpBaseScan = 1;
    params.newGroupName = sprintf('w-%s', params.groupName');
    concatTSeries(v, params);
end

end