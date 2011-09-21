module FamilyJewelsSpecHelper
  def build_config_for_spec
    FamilyJewels::Config.new(
      :gems_dir  => File.join(ENV['PWD'], 'tmp/spec/gems_dir'),
      :stage_dir => File.join(ENV['PWD'], 'tmp/spec/stage_dir')
    )
  end

  def hide_stderr(&block)
    old_stderr = $stderr
    $stderr = StringIO.new
    begin
      yield
    ensure
      $stderr = old_stderr
    end
  end

  def hide_stdout(&block)
    old_stdout = $stdout
    $stdout = StringIO.new
    begin
      yield
    ensure
      $stdout = old_stdout
    end
  end
end
