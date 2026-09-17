classdef AppLogger < handle
    %APPLOGGER Structured text logger for operator actions and hardware state.

    properties (SetAccess = private)
        FilePath string = ""
        SessionID string = "unassigned"
        OperatorID string = "unconfirmed"
        OperatorName string = "unconfirmed"
        PendingCount double = 0
    end

    properties (Access = private)
        FileID double = -1
        PendingLines cell = {}
    end

    methods
        function obj = AppLogger(logFolder)
            if nargin < 1 || strlength(string(logFolder)) == 0
                logFolder = fullfile(pwd, 'logs');
            end
            if ~exist(logFolder, 'dir')
                mkdir(logFolder);
            end
            stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
            obj.FilePath = string(fullfile(logFolder, ['app_' stamp '.log']));
            obj.FileID = fopen(obj.FilePath, 'a', 'n', 'UTF-8');
            if obj.FileID < 0
                error('ZouLab:LogOpenFailed', 'Cannot open log file: %s', obj.FilePath);
            end
            obj.log('INFO', 'APP_LOG_OPENED', 'LogFile=%s', obj.FilePath);
        end

        function setIdentity(obj, operatorID, operatorName)
            obj.OperatorID = string(operatorID);
            obj.OperatorName = string(operatorName);
            obj.log('INFO', 'OPERATOR_CONFIRMED', 'OperatorID=%s | OperatorName=%s', ...
                obj.OperatorID, obj.OperatorName);
        end

        function clearIdentity(obj, reason)
            if nargin < 2
                reason = 'unspecified';
            end
            previousID = obj.OperatorID;
            previousName = obj.OperatorName;
            obj.OperatorID = "unconfirmed";
            obj.OperatorName = "unconfirmed";
            obj.log('INFO', 'OPERATOR_CLEARED', ...
                'PreviousID=%s | PreviousName=%s | Reason=%s', ...
                previousID, previousName, string(reason));
        end

        function setSession(obj, sessionID)
            obj.SessionID = string(sessionID);
            obj.log('INFO', 'SESSION_ASSIGNED', 'SessionID=%s', obj.SessionID);
        end

        function log(obj, level, eventName, message, varargin)
            if obj.FileID < 0
                return;
            end
            if nargin > 4
                detail = sprintf(message, varargin{:});
            else
                detail = char(string(message));
            end
            detail = regexprep(detail, '[\r\n]+', ' ');
            timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            line = sprintf('%s | %-7s | %-32s | operator=%s/%s | session=%s | %s\n', ...
                timestamp, upper(char(string(level))), char(string(eventName)), ...
                char(obj.OperatorID), char(obj.OperatorName), char(obj.SessionID), detail);
            obj.PendingLines{end + 1} = line;
            obj.PendingCount = numel(obj.PendingLines);
        end

        function flush(obj)
            %FLUSH Commit queued log lines in one disk write.
            if obj.FileID < 0 || isempty(obj.PendingLines)
                return;
            end
            payload = [obj.PendingLines{:}];
            fprintf(obj.FileID, '%s', payload);
            status = fclose(obj.FileID);
            obj.FileID = -1;
            if status ~= 0
                error('ZouLab:LogFlushFailed', ...
                    'Could not close the log file after a batch write: %s', ...
                    obj.FilePath);
            end
            obj.PendingLines = {};
            obj.PendingCount = 0;
            obj.FileID = fopen(obj.FilePath, 'a', 'n', 'UTF-8');
            if obj.FileID < 0
                error('ZouLab:LogReopenFailed', ...
                    'Could not reopen the log file after a batch write: %s', ...
                    obj.FilePath);
            end
        end

        function lines = recentLines(obj, maximumLines)
            %RECENTLINES Return persisted and queued lines for the in-app view.
            if nargin < 2
                maximumLines = 200;
            end
            lines = strings(0, 1);
            if isfile(obj.FilePath)
                persisted = splitlines(string(fileread(obj.FilePath)));
                persisted(persisted == "") = [];
                lines = persisted(:);
            end
            if ~isempty(obj.PendingLines)
                pending = string(obj.PendingLines(:));
                pending = regexprep(pending, '[\r\n]+$', '');
                lines = [lines; pending];
            end
            if numel(lines) > maximumLines
                lines = lines(end - maximumLines + 1:end);
            end
        end

        function discard(obj)
            %DISCARD Close without writing queued lines (forced window close).
            obj.PendingLines = {};
            obj.PendingCount = 0;
            if obj.FileID >= 0
                fclose(obj.FileID);
                obj.FileID = -1;
            end
        end

        function logException(obj, eventName, exception)
            obj.log('ERROR', eventName, '%s | %s | %s', exception.identifier, ...
                exception.message, getReport(exception, 'basic', 'hyperlinks', 'off'));
        end

        function close(obj)
            if obj.FileID >= 0
                obj.log('INFO', 'APP_LOG_CLOSED', 'Logger closed normally.');
                obj.flush();
                fclose(obj.FileID);
                obj.FileID = -1;
            end
        end

        function delete(obj)
            obj.close();
        end
    end
end
