require 'json'

module Jekyll
  class GraphGenerator < Generator
    safe true

    def parse_filename(filename)
        # .md 확장자 제거
        name_without_extension = File.basename(filename, ".md")
        
        # 날짜 부분 제거 (형식: YYYY-MM-DD)
        # split으로 날짜를 포함한 첫 3부분을 가져와서 나머지를 조인
        parts = name_without_extension.split('-')
        
        # 날짜를 제외한 나머지 부분을 조인하여 반환
        parsed_name = parts[3..-1].join('-')
        
        return parsed_name
    end

    def generate(site)
      graph_data = []
      nodes = []

      # 모든 포스트를 순회
      site.posts.docs.each do |post|
        # 노드 filepath
        parsed_name = parse_filename(post.basename)
        # 노드 추가: 포스트 제목
        nodes << { id: post.data['title'], self: parsed_name} unless nodes.any? { |n| n[:id] == post.data['title'] }

        # 관련 포스트를 가져옴 (파일 이름)
        related_posts = post.data['related_posts'] || []
        
        puts "Processing post: #{post.data['title']}"  # 현재 포스트 제목 출력

        related_posts.each do |related|
          # 관련 포스트 제목을 찾기
          related_post = site.posts.docs.find { |p| p.basename == related }
          
          if related_post
            graph_data << {
              source: post.data['title'],
              target: related_post.data['title'] # 프론트 매터의 제목 사용
            }
            puts "Found related post: #{related_post.data['title']}" # 찾은 관련 포스트 제목 출력
          else
            puts "Related post not found for: #{related}" # 관련 포스트를 찾지 못했을 경우 출력
          end
        end
      end

      # JSON 데이터 형식 만들기
      json_data = {
        nodes: nodes,
        links: graph_data
      }

      # JSON 파일로 저장
      if json_data[:links].empty? && nodes.empty?
        puts "No graph data to save."
      else
        File.open("assets/graph.json", "w") do |f|
          f.write(json_data.to_json)
        end
        puts "Graph data saved successfully."
      end
    end
  end
end