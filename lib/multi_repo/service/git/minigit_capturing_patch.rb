module MultiRepo
  module Git
    module MiniGitCapturingPatch
      def system(*args)
        `#{Shellwords.join(args)} 2>&1`
      end
    end
  end
end

require "minigit"
MiniGit::Capturing.prepend(MultiRepo::Git::MiniGitCapturingPatch)
